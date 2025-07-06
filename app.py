# pylint: disable=missing-module-docstring,missing-function-docstring
# cspell: disable
import os

import oracledb
from flask import Flask, redirect, render_template, request, session

app = Flask(__name__)
app.secret_key = os.getenv("FLASK_SECRET_KEY", "default_secret_key")

conn = oracledb.connect(
    user="brendanbadhe", password="bren1234", dsn="localhost:1521/XEPDB1"
)


@app.route("/")
def home():
    return redirect("/login")


@app.route("/login", methods=["GET", "POST"])
def login():
    error = None
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        cursor = conn.cursor()
        cursor.execute(
            "SELECT user_id FROM users WHERE username = :1 AND password = :2",
            (username, password),
        )
        user = cursor.fetchone()
        cursor.close()

        if user:
            session["user_id"] = user[0]
            return redirect("/products")
        else:
            error = "Invalid credentials. Try again."

    return render_template("login.html", error=error)


@app.route("/signup", methods=["GET", "POST"])
def signup():
    error = None
    if request.method == "POST":
        username = request.form["username"]
        email = request.form["email"]
        password = request.form["password"]
        confirm_password = request.form["confirm_password"]

        if password != confirm_password:
            error = "Passwords do not match."
        else:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "INSERT INTO users (user_id, username, email, password) "
                    "VALUES (users_seq.NEXTVAL, :1, :2, :3)",
                    (username, email, password),
                )
                conn.commit()
                return redirect("/login")
            except oracledb.IntegrityError:
                error = "Username or email already exists."
            finally:
                cursor.close()

    return render_template("signup.html", error=error)


@app.route("/products")
def products():
    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    cursor = conn.cursor()
    cursor.execute(
        "SELECT product_id, name, description, price, quantity FROM products"
    )
    items = cursor.fetchall()

    cursor.execute(
        "SELECT product_id FROM shopping_cart_items WHERE user_id = :1",
        (user_id,),
    )
    cart_items = {row[0] for row in cursor.fetchall()}
    cursor.close()
    return render_template("products.html", products=items, cart_items=cart_items)


@app.route("/add_to_cart/<int:product_id>", methods=["POST"])
def add_to_cart(product_id):
    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    cursor = conn.cursor()
    try:
        cursor.callproc("add_to_cart", [user_id, product_id])
        conn.commit()
    finally:
        cursor.close()

    return redirect("/products")


@app.route("/cart")
def cart():
    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    cursor = conn.cursor()
    try:
        cursor.execute(
            "SELECT p.product_id, p.name, p.description, p.price, sci.quantity, p.quantity "
            "FROM shopping_cart_items sci "
            "JOIN products p ON sci.product_id = p.product_id "
            "WHERE sci.user_id = :1",
            (user_id,),
        )
        cart_items = cursor.fetchall()
        cart_total = cursor.callfunc("get_cart_total", oracledb.NUMBER, [user_id])
    finally:
        cursor.close()
    return render_template("cart.html", cart_items=cart_items, cart_total=cart_total)


@app.route("/increment_quantity/<int:product_id>", methods=["POST"])
def increment_quantity(product_id):
    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    cursor = conn.cursor()
    try:
        cursor.callproc("increment_quantity", [user_id, product_id])
        conn.commit()
    finally:
        cursor.close()

    return redirect("/cart")


@app.route("/decrement_quantity/<int:product_id>", methods=["POST"])
def decrement_quantity(product_id):
    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    cursor = conn.cursor()
    try:
        cursor.callproc("decrement_quantity", [user_id, product_id])
        conn.commit()
    finally:
        cursor.close()

    return redirect("/cart")


@app.route("/remove_from_cart/<int:product_id>", methods=["POST"])
def remove_from_cart(product_id):
    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    cursor = conn.cursor()
    try:
        cursor.callproc("remove_from_cart", [user_id, product_id])
        conn.commit()
    finally:
        cursor.close()

    return redirect("/cart")


@app.route("/checkout")
def checkout():
    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    cursor = conn.cursor()
    try:
        cursor.execute(
            "SELECT p.product_id, p.name, p.description, p.price, sci.quantity, p.quantity "
            "FROM shopping_cart_items sci "
            "JOIN products p ON sci.product_id = p.product_id "
            "WHERE sci.user_id = :1",
            (user_id,),
        )
        cart_items = cursor.fetchall()
        cart_total = cursor.callfunc("get_cart_total", oracledb.NUMBER, [user_id])
    finally:
        cursor.close()
    return render_template(
        "checkout.html", cart_items=cart_items, cart_total=cart_total
    )


@app.route("/place_order", methods=["POST"])
def place_order():
    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]
    shipping_address = request.form.get("shipping_address")

    if not shipping_address:
        return redirect("/cart")

    cursor = conn.cursor()
    try:
        cursor.callproc("place_order", [user_id, shipping_address])
        conn.commit()
    finally:
        cursor.close()

    return redirect("/orders")


@app.route("/orders")
def orders():
    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    cursor = conn.cursor()
    try:
        cursor.execute(
            "SELECT o.order_id, o.order_date, o.shipping_address, SUM(oi.quantity * oi.price) "
            "AS total FROM orders o "
            "JOIN order_items oi ON o.order_id = oi.order_id "
            "WHERE o.user_id = :1 GROUP BY o.order_id, o.order_date, o.shipping_address "
            "ORDER BY o.order_date DESC",
            (user_id,),
        )
        order_history = cursor.fetchall()
    finally:
        cursor.close()

    return render_template("orders.html", orders=order_history)


@app.route("/order_details/<int:order_id>")
def order_details(order_id):
    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    cursor = conn.cursor()
    try:
        cursor.execute(
            "SELECT p.name, p.description, oi.price, oi.quantity, (oi.price * oi.quantity) "
            "AS total FROM order_items oi JOIN products p ON oi.product_id = p.product_id "
            "WHERE oi.order_id = :1 "
            "AND EXISTS ( SELECT 1 FROM orders o WHERE o.order_id = :2 AND o.user_id = :3 )",
            (order_id, order_id, user_id),
        )
        order_items = cursor.fetchall()
        order_total = cursor.callfunc("get_order_total", oracledb.NUMBER, [order_id])
    finally:
        cursor.close()

    if not order_items:
        return redirect("/orders")

    return render_template(
        "order_details.html",
        order_items=order_items,
        order_id=order_id,
        order_total=order_total,
    )


@app.route("/logout")
def logout():
    session.pop("user_id", None)
    return redirect("/login")


if __name__ == "__main__":
    app.run(debug=True)
