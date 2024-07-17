### 问题描述
> 在项目中有时需要使用定时任务 如：统计数据等

### 解决方案
#### 解决方案一
> 在SpringBoot环境下，在启动类上添加注解**@EnableScheduling**
> ##### cron在线生成： [https://tool.lu/crontab/](https://tool.lu/crontab/)

##### 定时任务类
```java
@Component
public class ScheduledTask {

    @Autowired
    private StatisticsDailyService dailyService;

    /**
     * 测试
     * 每天七点到二十三点每五秒执行一次
     */
//    @Scheduled(cron = "0/5 * * * * ?")
//    public void task1() {
//        System.out.println("*********++++++++++++*****执行了");
//    }

    /**
     * 每天凌晨1点执行定时
     */
    @Scheduled(cron = "0 0 1 * * ?")
    public void task2() {
        //获取上一天的日期
        String day = DateUtil.formatDate(DateUtil.addDays(new Date(), -1));
        dailyService.createStatisticsByDay(day);

    }
}
```
