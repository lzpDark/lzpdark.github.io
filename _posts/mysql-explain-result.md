---
layout: post
title: "MySQL的explain结果怎么理解"
date: 2024-09-05
categories: mysql
---

MySQL的explain结果会显示这12列信息，这个笔记里记录一下常见的值分别代表什么意思，补充了一些例子。

```text
+----+-------------+----------+------------+-------+-------------------+-------------------+---------+------+------+----------+-----------------------+
| id | select_type | table    | partitions | type  | possible_keys     | key               | key_len | ref  | rows | filtered | Extra                 |
+----+-------------+----------+------------+-------+-------------------+-------------------+---------+------+------+----------+-----------------------+
```

### 1. id

查询的标识ID

### 2. select_type

查询的类型，`SIMPLE`/`PRIMARY` ...

### 3. table

explain结果对应那一行的数据表名称

### 4. partitions

可能匹配的分区，如果数据表不是分区表就显示`NULL`

### 5. type

描述table是如何`join`的，下面依次从最优到最糟糕排序。

#### system

> The table has only one row (= system table). This is a special case of the const join type.

#### const

> The table has at most one matching row, which is read at the start of the query. Because there is only one row, values from the column in this row can be regarded as constants by the rest of the optimizer. const tables are very fast because they are read only once.

#### eq_ref

官网manual里描述：
> One row is read from this table for each combination of rows from the previous tables. Other than the system and const types, this is the best possible join type. It is used when all parts of an index are used by the join and the index is a PRIMARY KEY or UNIQUE NOT NULL index.

看不太懂，求助chatGPT:

> In short, eq_ref means the table is being joined using an index in such a way that for each row in the preceding tables, MySQL can retrieve exactly one corresponding row using a primary key or unique key.

example:
```mysql
create table if not exists Customers (id int primary key, name varchar(50), email varchar(50));
create table if not exists Orders (id int primary key, customer_id int, amount double, foreign key (customer_id) references Customers(id));
explain select * from Orders join Customers on Orders.customer_id = Customers.id;
```
```text
+----+-------------+-----------+------------+--------+---------------+---------+---------+------------------------+------+----------+-------------+
| id | select_type | table     | partitions | type   | possible_keys | key     | key_len | ref                    | rows | filtered | Extra       |
+----+-------------+-----------+------------+--------+---------------+---------+---------+------------------------+------+----------+-------------+
|  1 | SIMPLE      | Orders    | NULL       | ALL    | customer_id   | NULL    | NULL    | NULL                   |    1 |   100.00 | Using where |
|  1 | SIMPLE      | Customers | NULL       | eq_ref | PRIMARY       | PRIMARY | 4       | tmp.Orders.customer_id |    1 |   100.00 | NULL        |
+----+-------------+-----------+------------+--------+---------------+---------+---------+------------------------+------+----------+-------------+
```

#### ref

from official manual:
> All rows with matching index values are read from this table for each combination of rows from the previous tables. ref is used if the join uses only a leftmost prefix of the key or if the key is not a PRIMARY KEY or UNIQUE index (in other words, if the join cannot select a single row based on the key value). If the key that is used matches only a few rows, this is a good join type.

example:
```mysql
create table if not exists Customers (id int primary key, name varchar(50), email varchar(50));
create table if not exists Orders (id int primary key, customer_id int, amount double, foreign key (customer_id) references Customers(id));
explain select * from Customers left join Orders on Customers.id = Orders.customer_id;
```
```text
+----+-------------+-----------+------------+------+---------------+-------------+---------+------------------+------+----------+-------+
| id | select_type | table     | partitions | type | possible_keys | key         | key_len | ref              | rows | filtered | Extra |
+----+-------------+-----------+------------+------+---------------+-------------+---------+------------------+------+----------+-------+
|  1 | SIMPLE      | Customers | NULL       | ALL  | NULL          | NULL        | NULL    | NULL             |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | Orders    | NULL       | ref  | customer_id   | customer_id | 5       | tmp.Customers.id |    1 |   100.00 | NULL  |
+----+-------------+-----------+------------+------+---------------+-------------+---------+------------------+------+----------+-------+
```

#### fulltext

```mysql
create table if not exists Customers (id int primary key, name varchar(50), email varchar(50));
create fulltext index idx_fulltext_email on Customers(email);
explain select * from Customers where match(email) against ('gmail' in natural language mode);
```
```text
+----+-------------+-----------+------------+----------+--------------------+--------------------+---------+-------+------+----------+-------------------------------+
| id | select_type | table     | partitions | type     | possible_keys      | key                | key_len | ref   | rows | filtered | Extra                         |
+----+-------------+-----------+------------+----------+--------------------+--------------------+---------+-------+------+----------+-------------------------------+
|  1 | SIMPLE      | Customers | NULL       | fulltext | idx_fulltext_email | idx_fulltext_email | 0       | const |    1 |   100.00 | Using where; Ft_hints: sorted |
+----+-------------+-----------+------------+----------+--------------------+--------------------+---------+-------+------+----------+-------------------------------+
```

#### ref_or_null

```mysql
create table if not exists Customers (id int primary key, name varchar(50), email varchar(50));
create index idx_customers_email on Customers(email);
explain select * from Customers where email = '1' or email is null;
```
```text
+----+-------------+-----------+------------+-------------+---------------------+---------------------+---------+-------+------+----------+-----------------------+
| id | select_type | table     | partitions | type        | possible_keys       | key                 | key_len | ref   | rows | filtered | Extra                 |
+----+-------------+-----------+------------+-------------+---------------------+---------------------+---------+-------+------+----------+-----------------------+
|  1 | SIMPLE      | Customers | NULL       | ref_or_null | idx_customers_email | idx_customers_email | 203     | const |    2 |   100.00 | Using index condition |
+----+-------------+-----------+------------+-------------+---------------------+---------------------+---------+-------+------+----------+-----------------------+
```

#### index_merge

> This join type indicates that the Index Merge optimization is used. In this case, the key column in the output row contains a list of indexes used, and key_len contains a list of the longest key parts for the indexes used. 

```mysql
create table if not exists table_index_merge (id int primary key, k1 int, k2 int);
create index idx_table_index_merge_k1 on table_index_merge(k1);
create index idx_table_index_merge_k2 on table_index_merge(k2);
insert into table_index_merge (id, k1, k2) values (1, 1, 1), (2, 10, 10), (3, 20, 20);
explain select * from table_index_merge where k1 = 10 or k2 = 20;
```
```text
+----+-------------+-------------------+------------+-------------+---------------------------------------------------+---------------------------------------------------+---------+------+------+----------+-----------------------------------------------------------------------------+
| id | select_type | table             | partitions | type        | possible_keys                                     | key                                               | key_len | ref  | rows | filtered | Extra                                                                       |
+----+-------------+-------------------+------------+-------------+---------------------------------------------------+---------------------------------------------------+---------+------+------+----------+-----------------------------------------------------------------------------+
|  1 | SIMPLE      | table_index_merge | NULL       | index_merge | idx_table_index_merge_k1,idx_table_index_merge_k2 | idx_table_index_merge_k1,idx_table_index_merge_k2 | 5,5     | NULL |    2 |   100.00 | Using union(idx_table_index_merge_k1,idx_table_index_merge_k2); Using where |
+----+-------------+-------------------+------------+-------------+---------------------------------------------------+---------------------------------------------------+---------+------+------+----------+-----------------------------------------------------------------------------+
1 row in set, 1 warning (0.00 sec)
```
#### unique_subquery

> This type replaces eq_ref for some IN subqueries of the following form:
> 
> `value IN (SELECT primary_key FROM single_table WHERE some_expr)`
> 
> is just an index lookup function that replaces the subquery completely for better efficiency.

example:

没能复现，按照上面的描述实测会显示 `eq_ref`

#### index_subquery

>This join type is similar to unique_subquery. It replaces IN subqueries, but it works for nonunique indexes in subqueries of the following form:
> 
> `value IN (SELECT key_column FROM single_table WHERE some_expr)`

没能复现，按照上面的描述实测会显示 `ref`。

#### range

> Only rows that are in a given range are retrieved, using an index to select the rows. The key column in the output row indicates which index is used. The key_len contains the longest key part that was used. The ref column is NULL for this type.
>
> range can be used when a key column is compared to a constant using any of the =, <>, >, >=, <, <=, IS NULL, <=>, BETWEEN, LIKE, or IN() operators

然而如果`where`条件里用了`=`, 实际测试`type`并不会显示`range`。

example:
```
create table Customer (id int primary key, name varchar(50));
explain select * from Customer where id > 10;
```
```text
+----+-------------+----------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
| id | select_type | table    | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
+----+-------------+----------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | Customer | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL |    1 |   100.00 | Using where |
+----+-------------+----------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
```


#### index

> The index join type is the same as ALL, except that the index tree is scanned. This occurs two ways:
>
> - If the index is a covering index for the queries and can be used to satisfy all data required from the table, only the index tree is scanned. In this case, the Extra column says Using index. An index-only scan usually is faster than ALL because the size of the index usually is smaller than the table data.
>
> - A full table scan is performed using reads from the index to look up data rows in index order. Uses index does not appear in the Extra column.
>
> MySQL can use this join type when the query uses only columns that are part of a single index.

example:
```mysql
create table Customer (id int primary key, name varchar(50));
create index idx_customer_name on Customer(name);
explain select name from Customer;
```
```text
+----+-------------+----------+------------+-------+---------------+-------------------+---------+------+------+----------+-------------+
| id | select_type | table    | partitions | type  | possible_keys | key               | key_len | ref  | rows | filtered | Extra       |
+----+-------------+----------+------------+-------+---------------+-------------------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | Customer | NULL       | index | NULL          | idx_customer_name | 203     | NULL |    1 |   100.00 | Using index |
+----+-------------+----------+------------+-------+---------------+-------------------+---------+------+------+----------+-------------+
```

#### ALL

> A full table scan is done for each combination of rows from the previous tables. This is normally not good if the table is the first table not marked const, and usually very bad in all other cases. Normally, you can avoid ALL by adding indexes that enable row retrieval from the table based on constant values or column values from earlier tables.

example:
```mysql
create table Customer (id int primary key, name varchar(50));
explain select * from Customer;
```
```text
+----+-------------+----------+------------+-------+---------------+-------------------+---------+------+------+----------+-------------+
| id | select_type | table    | partitions | type  | possible_keys | key               | key_len | ref  | rows | filtered | Extra       |
+----+-------------+----------+------------+-------+---------------+-------------------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | Customer | NULL       | index | NULL          | idx_customer_name | 203     | NULL |    1 |   100.00 | Using index |
+----+-------------+----------+------------+-------+---------------+-------------------+---------+------+------+----------+-------------+
```

### 6. possible_keys

可能用到的索引

### key

实际用的索引

### key_len

索引长度。

比如这个例子里：
```text
+----+-------------+----------+------------+-------+---------------+-------------------+---------+------+------+----------+-------------+
| id | select_type | table    | partitions | type  | possible_keys | key               | key_len | ref  | rows | filtered | Extra       |
+----+-------------+----------+------------+-------+---------------+-------------------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | Customer | NULL       | index | NULL          | idx_customer_name | 203     | NULL |    1 |   100.00 | Using index |
+----+-------------+----------+------------+-------+---------------+-------------------+---------+------+------+----------+-------------+
```
203的原因是name的长度是50，字符编码是utf8mb4，每个字符4字节，额外2字节的字符长度，额外1字节的是否NULL标记: `203 = 50 * 4 + 2 + 1`

### ref

> The ref column shows which columns or constants are compared to the index named in the key column to select rows from the table.
>
> If the value is func, the value used is the result of some function. To see which function, use SHOW WARNINGS following EXPLAIN to see the extended EXPLAIN output. The function might actually be an operator such as an arithmetic operator.

不太明白，从文档看应该显示`列名称`,`const`或者`func`，

### rows

数据数据行数

### filtered

实际返回数据占总扫描数据百分比

### Extra

额外的信息：

- using_index： 使用了覆盖索引，性能最优
- using where： 使用了where过滤扫描的数据。type是ALL时如果没有using where就是全表扫描，性能最糟糕，要避免。


# 其他资源

- 可视化explain的结果: https://mysqlexplain.com/
- 版本8.4官网manual：https://dev.mysql.com/doc/refman/8.4/en/explain-output.html