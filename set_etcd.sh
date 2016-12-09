#!/bin/bash
#
export ETCDCTL_PEERS="http://$(docker-machine ip oberd):5001" && \
export OBERD_UPSTREAM="$(docker-machine ip oberd):3501" && \
etcdctl set /nginx/apps/login.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM && \
etcdctl set /nginx/apps/cpanel.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM && \
etcdctl set /nginx/apps/form.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM && \
etcdctl set /nginx/apps/portal.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM && \
etcdctl set /nginx/apps/export.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM && \
etcdctl set /nginx/apps/cron.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM && \
etcdctl set /nginx/apps/login_old.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM && \
etcdctl set /nginx/apps/qcreator.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM && \
etcdctl set /nginx/apps/messaging.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM && \
etcdctl set /nginx/apps/media.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM

etcdctl set /nginx/apps/oauth2.oberd.dev/$OBERD_UPSTREAM $OBERD_UPSTREAM

etcdctl set /nginx/apps/rabbitmq.oberd.dev/$(docker-machine ip oberd):15672 $(docker-machine ip oberd):15672
etcdctl set /nginx/apps/mountain-service.oberd.dev/$(docker-machine ip oberd):3510 $(docker-machine ip oberd):3510
etcdctl set /nginx/apps/collaborators-api.oberd.dev/$(docker-machine ip oberd):3511 $(docker-machine ip oberd):3511
etcdctl set /nginx/apps/dashboards.oberd.dev/$(docker-machine ip oberd):3560 $(docker-machine ip oberd):3560