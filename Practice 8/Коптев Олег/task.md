# Homework 8
## Task 1
```sql
drop table if exists BookCategory;
drop table if exists Borrowing;
drop table if exists Book;
drop table if exists Publisher;
drop table if exists BookCopy;
drop table if exists Reader;
drop table if exists Category;

create table Category (
    cat_name char(20) primary key,
    parent_name char(20),
    foreign key (parent_name) references Category(cat_name)
);

create table Publisher (
    pub_name char(40) primary key,
    address char(120)
);

create table Reader (
    read_id integer primary key,
    first_name char(40),
    last_name char(40),
    address char(120),
    birthday char(10)
);

create table Book (
    isbn char(17) primary key,
    title char(40),
    author char(40),
    number_of_pages integer,
    published_date char(10),
    pub_name char(40),
    foreign key (pub_name) references Publisher(pub_name)
);

create table BookCopy (
    book_isbn char(17),
    copy_id integer,
    position integer,
    primary key (book_isbn, copy_id)
);

create table BookCategory (
    book_isbn char(17),
    cat_name char(20),
    foreign key (cat_name) references Category(cat_name),
    foreign key (book_isbn) references Book(isbn),
    primary key (cat_name, book_isbn)
);

create table Borrowing (
    copy_id integer,
    book_isbn char(17),
    read_id integer,
    return_date char(10),
    foreign key (book_isbn, copy_id) references BookCopy(book_isbn, copy_id),
    foreign key (read_id) references Reader(read_id),
    primary key (copy_id, book_isbn, read_id, return_date)
);
```

## Task 2

Project presents:
Java Spring REST API for Books table with two migration scripts.  
Connects to localhost:5432 by default (configurable at `src/main/resources/application.properties`)  
[GitHub link to project](https://github.com/OlegStanKoptev/db-hw-8-jdbc)