# This Dockerfile is used to build an headles vnc image based on Centos

FROM centos:7

MAINTAINER Starynets Yaroslav
ENV First 2020-04-15

LABEL io.k8s.description="Headless VNC Container with Xfce window manager, firefox and chromium" \
      io.k8s.display-name="Headless VNC Container based on Centos" \
      io.openshift.expose-services="6901:http,5901:xvnc" \
      io.openshift.tags="vnc, centos, xfce" \
      io.openshift.non-scalable=true

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=80
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
ENV USER=sysop \
    HOME=/home/sysop \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/home/sysop/install \
    NO_VNC_HOME=/home/sysop/noVNC \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

### Add all install scripts for further steps
ADD ./src/common/install/ $INST_SCRIPTS/
ADD ./src/centos/install/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN $INST_SCRIPTS/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

### Install firefox and chrome browser
RUN $INST_SCRIPTS/firefox.sh
RUN $INST_SCRIPTS/chrome.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./src/common/xfce/ $HOME/

### Niab
COPY niab.repo /etc/yum.repos.d/
RUN $INST_SCRIPTS/niab.sh

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
