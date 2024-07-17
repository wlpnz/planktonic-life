当我们在Mybatis的xml中写SQL查询数据时，有时会出现一对一或一对多的情况，这是可以使用**association关联**和**collection集合**标签处理
文中内容具体查询[Mybatis官网](https://mybatis.org/mybatis-3/zh/sqlmap-xml.html)
##### 关联association
关联（association）元素处理“有一个”类型的关系。也就是处理数据中一对一的关系
MyBatis 有两种不同的方式加载关联：

- 嵌套 Select 查询：通过执行另外一个 SQL 映射语句来加载期望的复杂类型。
- 嵌套结果映射：使用嵌套的结果映射来处理连接结果的重复子集。
###### 关联结果映射
```xml
<resultMap id="blogResult" type="Blog">
  <id property="id" column="blog_id" />
  <result property="title" column="blog_title"/>
  <association property="author" column="blog_author_id" 
    javaType="Author" resultMap="authorResult"/>
</resultMap>
# 这样写可以重用authorResult
<resultMap id="authorResult" type="Author">
  <id property="id" column="author_id"/>
  <result property="username" column="author_username"/>
  <result property="password" column="author_password"/>
  <result property="email" column="author_email"/>
  <result property="bio" column="author_bio"/>
</resultMap>
=================================================================
# 不打算重用的时候可以直接将结果映射作为子元素嵌套在内
<resultMap id="blogResult" type="Blog">
  <id property="id" column="blog_id" />
  <result property="title" column="blog_title"/>
  <association property="author" javaType="Author">
    <id property="id" column="author_id"/>
    <result property="username" column="author_username"/>
    <result property="password" column="author_password"/>
    <result property="email" column="author_email"/>
    <result property="bio" column="author_bio"/>
  </association>
</resultMap>
```
###### 关联的嵌套select查询
```xml
<resultMap id="blogResult" type="Blog">
  <association property="author" column="author_id" 
    javaType="Author" select="selectAuthor"/>
</resultMap>

<select id="selectAuthor" resultType="Author">
  SELECT * FROM AUTHOR WHERE ID = #{id}
</select>
```
###### 关联的多结果集（ResultSet）
| 属性 | 描述 |
| --- | --- |
| column | 当使用多个结果集时，该属性指定结果集中用于与 foreignColumn 匹配的列（多个列名以逗号隔开），以识别关系中的父类型与子类型。 |
| foreignColumn | 指定外键对应的列名，指定的列将与父类型中 column 的给出的列进行匹配。 |
| resultSet | 指定用于加载复杂类型的结果集名字。 |

多结果集查询时，可以使用ResultSet属性为每个结果集制定一个名字，多个名字使用逗号隔开
```xml
<select id="selectBlog" resultSets="blogs,authors" resultMap="blogResult" statementType="CALLABLE">
  {call getBlogsAndAuthors(#{id,jdbcType=INTEGER,mode=IN})}
</select>

<resultMap id="blogResult" type="Blog">
  <id property="id" column="id" />
  <result property="title" column="title"/>
  <association property="author" javaType="Author" 
    resultSet="authors" column="author_id" foreignColumn="id">
    <id property="id" column="id"/>
    <result property="username" column="username"/>
    <result property="password" column="password"/>
    <result property="email" column="email"/>
    <result property="bio" column="bio"/>
  </association>
</resultMap>
```
##### 集合collection
集合collection元素的用法几乎和联合association一样
首先会注意到使用的是collection，然后会注意到使用ofType属性，ofType用来将JavaBean(或字段)属性的类型和集合存储的类型区分开来。
```xml
<collection property="posts" javaType="ArrayList" column="id" 
  ofType="Post" select="selectPostsForBlog"/>
# 读作 “posts 是一个存储 Post 的 ArrayList 集合”
# 简写 忽略javaType
<collection property="posts" column="id"
  ofType="Post" select="selectPostsForBlog"/>
```
