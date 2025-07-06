--  cspell: disable
drop table shopping_cart_items;
drop table shopping_cart;
drop table order_items;
drop table orders;
drop table products;
drop table brands;
drop table categories;
drop table users;
drop sequence users_seq;
drop sequence categories_seq;
drop sequence brands_seq;
drop sequence products_seq;
drop sequence orders_seq;
drop procedure add_to_cart;
drop procedure increment_quantity;
drop procedure decrement_quantity;
drop procedure remove_from_cart;
drop procedure place_order;
drop function get_cart_total;
drop function get_order_total;

create table users (
   user_id    number primary key,
   username   varchar2(50) not null unique,
   email      varchar2(100) not null unique,
   password   varchar2(100) not null,
   created_at date default sysdate not null
);

create table categories (
   category_id number primary key,
   name        varchar2(50) not null unique,
   description varchar2(200)
);

create table brands (
   brand_id    number primary key,
   name        varchar2(50) not null unique,
   description varchar2(200)
);

create table products (
   product_id  number primary key,
   name        varchar2(100) not null,
   description varchar2(200),
   price       number(10,2) not null check ( price > 0 ),
   quantity    number not null check ( quantity >= 0 ),
   category_id number not null,
   brand_id    number not null,
   foreign key ( category_id )
      references categories ( category_id )
         on delete cascade,
   foreign key ( brand_id )
      references brands ( brand_id )
         on delete cascade
);

create table orders (
   order_id         number primary key,
   user_id          number not null,
   order_date       date default sysdate not null,
   shipping_address varchar2(200) not null,
   foreign key ( user_id )
      references users ( user_id )
         on delete cascade
);

create table order_items (
   order_id   number not null,
   product_id number not null,
   quantity   number not null check ( quantity > 0 ),
   price      number(10,2) not null check ( price > 0 ),
   primary key ( order_id,
                 product_id ),
   foreign key ( order_id )
      references orders ( order_id )
         on delete cascade,
   foreign key ( product_id )
      references products ( product_id )
         on delete cascade
);

create table shopping_cart (
   user_id      number primary key,
   created_date date default sysdate not null,
   foreign key ( user_id )
      references users ( user_id )
         on delete cascade
);

create table shopping_cart_items (
   user_id    number not null,
   product_id number not null,
   quantity   number not null,
   primary key ( user_id,
                 product_id ),
   foreign key ( user_id )
      references shopping_cart ( user_id )
         on delete cascade,
   foreign key ( product_id )
      references products ( product_id )
         on delete cascade
);

create sequence users_seq start with 1 increment by 1 nocache;
create sequence categories_seq start with 1 increment by 1 nocache;
create sequence brands_seq start with 1 increment by 1 nocache;
create sequence products_seq start with 1 increment by 1 nocache;
create sequence orders_seq start with 1 increment by 1 nocache;

insert into users (
   user_id,
   username,
   email,
   password
) values ( users_seq.nextval,
           'john_doe',
           'john@example.com',
           'password1' );

insert into users (
   user_id,
   username,
   email,
   password
) values ( users_seq.nextval,
           'jane_smith',
           'jane@example.com',
           'password2' );

insert into users (
   user_id,
   username,
   email,
   password
) values ( users_seq.nextval,
           'alex_jones',
           'alex@example.com',
           'password3' );

insert into categories (
   category_id,
   name,
   description
) values ( categories_seq.nextval,
           'Electronics',
           'Devices and gadgets' );

insert into categories (
   category_id,
   name,
   description
) values ( categories_seq.nextval,
           'Clothing',
           'Apparel and accessories' );

insert into categories (
   category_id,
   name,
   description
) values ( categories_seq.nextval,
           'Books',
           'Educational and fictional books' );

insert into brands (
   brand_id,
   name,
   description
) values ( brands_seq.nextval,
           'Apple',
           'Premium tech brand' );

insert into brands (
   brand_id,
   name,
   description
) values ( brands_seq.nextval,
           'Nike',
           'Sports and fashion brand' );

insert into brands (
   brand_id,
   name,
   description
) values ( brands_seq.nextval,
           'Samsung',
           'Electronics and appliances' );

insert into brands (
   brand_id,
   name,
   description
) values ( brands_seq.nextval,
           'Penguin Random House',
           'Leading book publisher' );

insert into products (
   product_id,
   name,
   description,
   price,
   quantity,
   category_id,
   brand_id
) values ( products_seq.nextval,
           'iPhone 15',
           'Latest Apple smartphone',
           999.99,
           50,
           1,
           1 );

insert into products (
   product_id,
   name,
   description,
   price,
   quantity,
   category_id,
   brand_id
) values ( products_seq.nextval,
           'Galaxy S23',
           'Samsung flagship phone',
           899.99,
           40,
           1,
           3 );

insert into products (
   product_id,
   name,
   description,
   price,
   quantity,
   category_id,
   brand_id
) values ( products_seq.nextval,
           'Nike Running Shoes',
           'Comfortable sports shoes',
           120.50,
           100,
           2,
           2 );

insert into products (
   product_id,
   name,
   description,
   price,
   quantity,
   category_id,
   brand_id
) values ( products_seq.nextval,
           'MacBook Pro',
           'Apple laptop with M3 chip',
           1999.00,
           30,
           1,
           1 );

insert into products (
   product_id,
   name,
   description,
   price,
   quantity,
   category_id,
   brand_id
) values ( products_seq.nextval,
           'Python Programming',
           'Guide to Python development',
           49.99,
           200,
           3,
           4 );

insert into orders (
   order_id,
   user_id,
   shipping_address
) values ( orders_seq.nextval,
           1,
           '123 Main St, New York, NY' );

insert into orders (
   order_id,
   user_id,
   shipping_address
) values ( orders_seq.nextval,
           2,
           '456 Elm St, Los Angeles, CA' );

insert into orders (
   order_id,
   user_id,
   shipping_address
) values ( orders_seq.nextval,
           3,
           '789 Oak St, Chicago, IL' );

insert into order_items (
   order_id,
   product_id,
   quantity,
   price
) values ( 1,
           1,
           1,
           999.99 );

insert into order_items (
   order_id,
   product_id,
   quantity,
   price
) values ( 1,
           3,
           2,
           120.50 );

insert into order_items (
   order_id,
   product_id,
   quantity,
   price
) values ( 2,
           2,
           1,
           899.99 );

insert into order_items (
   order_id,
   product_id,
   quantity,
   price
) values ( 3,
           5,
           3,
           49.99 );

insert into shopping_cart ( user_id ) values ( 1 );
insert into shopping_cart ( user_id ) values ( 2 );
insert into shopping_cart ( user_id ) values ( 3 );

insert into shopping_cart_items (
   user_id,
   product_id,
   quantity
) values ( 1,
           4,
           1 );

insert into shopping_cart_items (
   user_id,
   product_id,
   quantity
) values ( 1,
           2,
           1 );

insert into shopping_cart_items (
   user_id,
   product_id,
   quantity
) values ( 2,
           3,
           2 );

insert into shopping_cart_items (
   user_id,
   product_id,
   quantity
) values ( 3,
           5,
           1 );

create or replace trigger create_cart_after_user after
   insert on users
   for each row
begin
   insert into shopping_cart ( user_id ) values ( :new.user_id );
end;
/

create or replace procedure add_to_cart (
   p_user_id    in number,
   p_product_id in number
) as
begin
   insert into shopping_cart_items (
      user_id,
      product_id,
      quantity
   ) values ( p_user_id,
              p_product_id,
              1 );

   update products
      set
      quantity = quantity - 1
    where product_id = p_product_id
      and quantity > 0;
end;
/

create or replace function get_cart_total (
   p_user_id in number
) return number is
   v_total number := 0;
begin
   select sum(sci.quantity * p.price)
     into v_total
     from shopping_cart_items sci
     join products p
   on sci.product_id = p.product_id
    where sci.user_id = p_user_id;
   return nvl(
      v_total,
      0
   );
end;
/

create or replace procedure increment_quantity (
   p_user_id    in number,
   p_product_id in number
) as
begin
   update shopping_cart_items
      set
      quantity = quantity + 1
    where user_id = p_user_id
      and product_id = p_product_id;

   update products
      set
      quantity = quantity - 1
    where product_id = p_product_id
      and quantity > 0;
end;
/

create or replace procedure decrement_quantity (
   p_user_id    in number,
   p_product_id in number
) as
begin
   update shopping_cart_items
      set
      quantity = quantity - 1
    where user_id = p_user_id
      and product_id = p_product_id
      and quantity > 1;

   update products
      set
      quantity = quantity + 1
    where product_id = p_product_id;
end;
/

create or replace procedure remove_from_cart (
   p_user_id    in number,
   p_product_id in number
) as
   v_quantity number;
begin
   select quantity
     into v_quantity
     from shopping_cart_items
    where user_id = p_user_id
      and product_id = p_product_id;

   delete from shopping_cart_items
    where user_id = p_user_id
      and product_id = p_product_id;

   update products
      set
      quantity = quantity + v_quantity
    where product_id = p_product_id;
end;
/

create or replace procedure place_order (
   p_user_id          in number,
   p_shipping_address in varchar2
) as
   v_order_id number;
begin
   insert into orders (
      order_id,
      user_id,
      shipping_address
   ) values ( orders_seq.nextval,
              p_user_id,
              p_shipping_address ) returning order_id into v_order_id;

   insert into order_items (
      order_id,
      product_id,
      quantity,
      price
   )
      select v_order_id,
             sci.product_id,
             sci.quantity,
             p.price
        from shopping_cart_items sci
        join products p
      on sci.product_id = p.product_id
       where sci.user_id = p_user_id;

   delete from shopping_cart_items
    where user_id = p_user_id;
end;
/

create or replace function get_order_total (
   p_order_id in number
) return number is
   v_total number := 0;
begin
   select sum(oi.quantity * oi.price)
     into v_total
     from order_items oi
    where oi.order_id = p_order_id;

   return nvl(
      v_total,
      0
   );
end;
/

commit;