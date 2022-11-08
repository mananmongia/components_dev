import yaml
import os

dockercompose=open('/home/mithun/docker-compose.yml','r')
conf=yaml.load(dockercompose, Loader=yaml.FullLoader)
dockercompose.close()


conf['services']['nginx']['restart']='always'
conf['services']['nginx']['ports'][0]['published']='${DD_PORT:-8000}'
conf['services']['mysql']['restart']='always'
conf['services']['uwsgi']['restart']='always'
conf['services']['celerybeat']['restart']='always'
conf['services']['celeryworker']['restart']='always'
conf['services']['rabbitmq']['restart']='always'

dockercompose=open('/home/mithun/docker-compose.yml','w')
yaml.dump(conf,dockercompose, sort_keys=False)