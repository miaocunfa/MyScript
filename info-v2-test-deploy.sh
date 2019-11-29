cp /var/lib/jenkins/workspace/info-v2-test/info-scheduler-service/target/info-scheduler-service-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-common/target/info-common-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-admin/target/info-admin-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-groupon-service/target/info-groupon-service-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-payment-service/target/info-payment-service-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-config/target/info-config-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-message-service/target/info-message-service-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-nearby-service/target/info-nearby-service-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-uc-service/target/info-uc-service-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-community-service/target/info-community-service-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-ad-service/target/info-ad-service-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-auth-service/target/info-auth-service-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-hotel-service/target/info-hotel-service-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-security/target/info-security-0.0.1-SNAPSHOT.jar /root/aihangxunxi
cp /var/lib/jenkins/workspace/info-v2-test/info-gateway/target/info-gateway-0.0.1-SNAPSHOT.jar /root/aihangxunxi

cd /root/aihangxunxi

mv info-scheduler-service-0.0.1-SNAPSHOT.jar  info-scheduler-service.jar
mv info-common-0.0.1-SNAPSHOT.jar  info-common.jar
mv info-admin-0.0.1-SNAPSHOT.jar  info-admin.jar
mv info-groupon-service-0.0.1-SNAPSHOT.jar  info-groupon-service.jar
mv info-payment-service-0.0.1-SNAPSHOT.jar  info-payment-service.jar
mv info-config-0.0.1-SNAPSHOT.jar  info-config.jar
mv info-message-service-0.0.1-SNAPSHOT.jar  info-message-service.jar
mv info-nearby-service-0.0.1-SNAPSHOT.jar  info-nearby-service.jar
mv info-uc-service-0.0.1-SNAPSHOT.jar  info-uc-service.jar
mv info-community-service-0.0.1-SNAPSHOT.jar  info-community-service.jar
mv info-ad-service-0.0.1-SNAPSHOT.jar  info-ad-service.jar
mv info-auth-service-0.0.1-SNAPSHOT.jar  info-auth-service.jar
mv info-hotel-service-0.0.1-SNAPSHOT.jar  info-hotel-service.jar
mv info-security-0.0.1-SNAPSHOT.jar  info-security.jar
mv info-gateway-0.0.1-SNAPSHOT.jar  info-gateway.jar

cd /root

tar -zcvf aihangxunxi.tar.gz ./aihangxunxi

sshpass -p 'test123' ssh -o StrictHostKeyChecking=no aihangxunxi.tar.gz root@192.168.100.225:/opt/aihangxunxi/lib

sshpass -p 'test123' ssh -o StrictHostKeyChecking=no root@$192.168.100.225 > /dev/null 2>&1 << EOF
cd /opt/aihangxunxi/lib
tar -zxvf aihangxunxi.tar.gz
cd aihangxunxi
mv info-scheduler-service.jar ../
mv info-common.jar ../
mv info-admin.jar ../
mv info-groupon-service.jar ../
mv info-payment-service.jar ../
mv info-config.jar ../
mv info-message-service.jar ../
mv info-nearby-service.jar ../
mv info-uc-service.jar ../
mv info-community-service.jar ../
mv info-ad-service.jar ../
mv info-auth-service.jar ../
mv info-hotel-service.jar ../
mv info-security.jar ../
mv info-gateway.jar ../

cd /opt
./consul agent -dev -advertise 127.0.0.1 -enable-local-script-checks -client=0.0.0.0

sh /opt/aihangxunxi/bin/start.sh info-config.jar
sh /opt/aihangxunxi/bin/start.sh info-gateway.jar
sh /opt/aihangxunxi/bin/start.sh info-payment-service.jar
sh /opt/aihangxunxi/bin/start.sh info-message-service.jar
sh /opt/aihangxunxi/bin/start.sh info-nearby-service.jar
sh /opt/aihangxunxi/bin/start.sh info-uc-service.jar
sh /opt/aihangxunxi/bin/start.sh info-community-service.jar
sh /opt/aihangxunxi/bin/start.sh info-ad-service.jar
sh /opt/aihangxunxi/bin/start.sh info-auth-service.jar
sh /opt/aihangxunxi/bin/start.sh info-hotel-service.jar
sh /opt/aihangxunxi/bin/start.sh info-security.jar
sh /opt/aihangxunxi/bin/start.sh info-scheduler-service.jar
sh /opt/aihangxunxi/bin/start.sh info-common.jar
sh /opt/aihangxunxi/bin/start.sh info-groupon-service.jar

EOF
