---

---

**MySQL5升级到8的兼容问题**
**SQL语法解析的顺序**
SQL 查询的执行顺序通常与查询语句的书写顺序不同。理解 SQL 查询的执行顺序有助于优化查询性能和正确编写查询。以下是 SQL 查询的典型执行顺序：

1. FROM 子句：确定查询的数据源，包含表的连接操作。
2. WHERE 子句：应用过滤条件，排除不符合条件的行。
3. GROUP BY 子句：根据指定的列将数据分组。
4. HAVING 子句：应用过滤条件到分组后的数据。
5. SELECT 子句：选择需要的列，并执行任何计算或表达式。
6. DISTINCT 子句：去除结果集中重复的行。
7. ORDER BY 子句：对结果集进行排序。
8. LIMIT 子句：限制返回的行数。

配置文件位置：
windows： C:\ProgramData\MySQL\MySQL Server 8.0\my.ini
linux: /etc/my.cnf
#### sql-mode
MySQL 配置 sql-mode 的作用是控制 MySQL 如何处理**特定 SQL 语法和数据验证规则**。sql-mode 可以设置为多个模式的组合，以启用或禁用特定的功能或行为，从而影响 MySQL 的行为方式。通过设置不同的 sql-mode，可以更严格或更宽松地执行 SQL 语句，并且可以提高数据库的**兼容性和一致性**。
属性值

- STRICT_TRANS_TABLES
   - 如果一个值不能插入到事务表中，则会引发错误并回滚该语句。这有助于确保数据的完整性。
- STRICT_ALL_TABLES
   - 与 STRICT_TRANS_TABLES 类似，但适用于所有类型的表。
- NO_ZERO_IN_DATE
   - 不允许日期和月份中使用零值。例如，不允许 2024-00-12 或 2024-12-00 作为有效日期。
- NO_ZERO_DATE
   - 不允许使用 0000-00-00 作为有效日期，插入这样的日期会引发错误。
- **ONLY_FULL_GROUP_BY**
   - 使 GROUP BY 子句严格遵守 SQL 标准，要求 SELECT 列表中的所有列要么是聚合函数的一部分，要么在 GROUP BY 子句中列出。
   - 同样的逻辑也适用于 SELECT DISTINCT 子句中的 ORDER BY 子句。
- NO_ENGINE_SUBSTITUTION
   - 如果指定的存储引擎不可用，则会引发错误，而不是使用默认存储引擎替代。
- ANSI_QUOTES
   - 允许使用双引号（"）作为标识符引用字符，而不是字符串引用字符。
- PIPES_AS_CONCAT
   - 将管道符号 (||) 解释为字符串连接操作符，而不是逻辑 OR。
   - SELECT 'A' || 'B';  -- 结果是 'AB'
- TRADITIONAL
   - 这是多个严格模式的组合，包括 STRICT_TRANS_TABLES, STRICT_ALL_TABLES, NO_ZERO_IN_DATE, NO_ZERO_DATE, ERROR_FOR_DIVISION_BY_ZERO 等等。它使得 MySQL 在处理数据时更加严格，防止插入或更新无效数据。
- ERROR_FOR_DIVISION_BY_ZERO
   - 在插入或更新过程中出现除以零的情况时引发错误。
- HIGH_NOT_PRECEDENCE
   - 修改 NOT 运算符的优先级，使其与标准 SQL 的优先级一致。



MySQL8兼容MySQL5的sql，删除**ONLY_FULL_GROUP_BY**

`sql-mode="STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"`



#### 去重与排序的冲突
当sql-mode的值有`ONLY_FULL_GROUP_BY`时，order by后的排序字段要在selelct distinct的查询列表中
解决：

- 在select distinct 后加入排序字段
- 在my.cnf 或 my.ini 的 [mysqld] 后设置sql-mode的值，删除`ONLY_FULL_GROUP_BY`

