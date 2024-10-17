DROP DATABASE IF EXISTS `Library`;
CREATE DATABASE `Library`;

USE `Library`;

-- Table structure for table `author`

DROP TABLE IF EXISTS `author`;
CREATE TABLE `author` (
  `author_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(51) NOT NULL,
  PRIMARY KEY (`author_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `author`

LOCK TABLES `author` WRITE;
UNLOCK TABLES;

-- Table structure for table `book`

DROP TABLE IF EXISTS `book`;
CREATE TABLE `book` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `isbn` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `author_id` int(11) NOT NULL,
  `publishdate` date DEFAULT NULL,
  `stock` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `isbn` (`isbn`),
  KEY `author_id` (`author_id`),
  KEY `name` (`name`),
  CONSTRAINT `book_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `author` (`author_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `book`

LOCK TABLES `book` WRITE;
UNLOCK TABLES;

-- Table structure for table `usr`

DROP TABLE IF EXISTS `usr`;
CREATE TABLE `usr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(51) NOT NULL,
  `email` varchar(100) NOT NULL,
  `pwd` varchar(64) NOT NULL,
  `phone` int(11) DEFAULT NULL,
  `registerdate` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `usr`

LOCK TABLES `usr` WRITE;
UNLOCK TABLES;

-- Table structure for table `loan`

DROP TABLE IF EXISTS `loan`;
CREATE TABLE `loan` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usr_id` int(11) DEFAULT NULL,
  `book_id` int(11) DEFAULT NULL,
  `loandate` date DEFAULT NULL,
  `returndate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `book_id` (`book_id`),
  KEY `usr_id` (`usr_id`),
  CONSTRAINT `loan_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `book` (`id`),
  CONSTRAINT `loan_ibfk_3` FOREIGN KEY (`usr_id`) REFERENCES `usr` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table `loan`

LOCK TABLES `loan` WRITE;
UNLOCK TABLES;

-- Dumping routines for database 'Library'

DELIMITER ;;
CREATE PROCEDURE `add_user`(IN `myemail` VARCHAR(100), IN `myname` VARCHAR(51), IN `mypwd` VARCHAR(64), IN `myphone` INT)
begin 
insert into usr (email, name, pwd, phone, registerdate) values (
    myemail,
    myname,
    password(concat(mypwd, myemail)),
    myphone,
    date(now())
);
end ;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE `delete_book`(myisbn int)
begin 
declare n int default null;
select book.isbn into n from book where book.isbn = myisbn;
if n is null then
select '沒這本書' as message;
else
delete from book where  book.isbn = myisbn;
end if;
end ;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE `insert_book`(myname varchar(100), myauthor varchar(51), myisbn int, mypublishdate date, myamount tinyint)
begin 
declare n int default null ;
select author_id into n from author where name = myauthor;
if n is null then
insert into author (name) values (myauthor);
set n = LAST_INSERT_ID();
insert into book (name, isbn, publishdate, stock, author_id) values (
    myname,
    myisbn,
    mypublishdate,
    myamount,
    n
);
else 
insert into book (name, isbn, publishdate, stock, author_id) values (
    myname,
    myisbn,
    mypublishdate,
    myamount,
    n
);
end if;
end ;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE `loan_book`(usr int, book int)
begin 
declare n int default 0;
select stock into n from book where id = book;
if n > 0 then
insert into loan (usr_id, book_id, loandate) values (usr, book, now());
update book set stock = n - 1 where id = book;
select date(adddate(now(), +28)) as '最後還書日期';
else 
select '本書前次借閱並未建立歸還時間' as error_message;
end if;
end ;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE `return_book`(usr int, book int)
begin 
declare n int default 0;
declare i datetime default null;
select stock into n from book where id = book;
select returndate into i from loan where book_id = book;
if i is null then
update loan set returndate = now() where usr_id = usr and book_id = book;
update book set stock = n + 1 where id = book;
else 
select '本書以建立歸還資料' as error_message;
end if;
end ;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE `search_author`(name varchar(51))
BEGIN
SELECT author.name as '作者', book.name as '書名', stock as '在架'  
FROM author left join book on author.author_id = book.author_id
WHERE author.name = name;
end ;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE `search_book`(IN `name` VARCHAR(100))
begin
SELECT book.name as '書名', author.name as '作者', stock as '在架'  
FROM book left join author on book.author_id = author.author_id
WHERE book.name = name;
end ;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE `search_loan`(myid int)
begin 
declare n int default null;
select loan.book_id into n from loan where loan.usr_id = myid;
if n is null THEN
select '沒有借書紀錄' as 'message';
else
select book.name as '書名', loan.loandate as '借書日', ifnull(loan.returndate, '還沒還書') as '還書日'
from loan left join book on loan.book_id = book.id
where loan.usr_id = myid;
end if;
end ;;
DELIMITER ;
