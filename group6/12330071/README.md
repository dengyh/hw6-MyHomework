1. install MonogoDB
2. run mongod (on default port 27017)
3. npm install
4. grunt watch
5. 在浏览器中输入localhost:5000

6. 上传的文件在 /bin/public/uploads/目录下, grunt中的clean会忽略掉该文件夹
7. 老师需要在注册界面中注册, 暂时可以无限注册老师, 且老师都不分身份(即所有老师都可以修改作业,不管作业是否是自己创建的)
8. 截止日期的限制暂时只在前端进行了限制, 接口处并没有做验证
9. 所有接口的调用都有对调用者的身份进行验证, 比如学生哪怕输入修改作业的url, 也进入不了
10. 创建课程时, 没有对截止日期的规范进行验证
