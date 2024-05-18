---
layout: post
title: "spring-data-jpa"
date: 2024-04-28
categories: spring
---

# spring-data-jpa

#### How to use spring-data-jpa

add depend

```xml

```

define entity

```java
import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "test1")
public class TestEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name")
    private String name;
}
```

define repository interface

```java
import org.springframework.data.repository.CrudRepository;

public interface TestEntityRepository extends CrudRepository<TestEntity, Long> {
}
```

config connection

```properties
spring.datasource.url=jdbc:mysql://***
spring.datasource.username=***
spring.datasource.password=***
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
```



#### How spring-jpa works



#### How to use spring-data-jdbc

[examples](https://github.com/spring-projects/spring-data-examples/tree/main/jdbc/basics/src/main/java/example/springdata/jdbc/basics/aggregate)