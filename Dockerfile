FROM ubuntu:16.04

LABEL maintainer Mario Werner <mario.werner@iaik.tugraz.at>

#install dependencies:
# * wget -> to fetch the vivado file from a server
# * build-essential, cmake, gettext-base, git, python3 -> (gcc/g++/make/... for building high level models and for scripting)
# * libx... -> to make the installer and the gui tools happy
# * libgtk2.0-0 -> required for running xsdk
RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  gettext-base \
  git \
  libgtk2.0-0 \
  libxi6 \
  libxrender1 \
  libxtst6 \
  python3 \
  python3-pip \
  python3-venv \
  wget

# copy in config file
COPY install_config.txt /

# download and run the install
ARG VIVADO_TAR_HOST
ARG VIVADO_TAR_FILE
RUN echo "Downloading ${VIVADO_TAR_FILE} from ${VIVADO_TAR_HOST}" && \
  wget ${VIVADO_TAR_HOST}/${VIVADO_TAR_FILE}.tar.gz -q && \
  echo "Extracting Vivado tar file" && \
  tar xzf ${VIVADO_TAR_FILE}.tar.gz && \
  rm -rf ${VIVADO_TAR_FILE}.tar.gz && \
  /${VIVADO_TAR_FILE}/xsetup --agree 3rdPartyEULA,WebTalkTerms,XilinxEULA --batch Install --config install_config.txt && \
  rm -rf ${VIVADO_TAR_FILE}*

# export the license server as environment variable
ARG LICENSE_SERVER
ENV XILINXD_LICENSE_FILE=${LICENSE_SERVER}

# copy call wrapper into the container and setup symlinks for the most important commands
COPY run_in_xilinx_env /usr/local/bin
RUN ln -s /usr/local/bin/run_in_xilinx_env /usr/local/bin/bootgen && \
  ln -s /usr/local/bin/run_in_xilinx_env /usr/local/bin/vivado && \
  ln -s /usr/local/bin/run_in_xilinx_env /usr/local/bin/xelab && \
  ln -s /usr/local/bin/run_in_xilinx_env /usr/local/bin/xmd && \
  ln -s /usr/local/bin/run_in_xilinx_env /usr/local/bin/xsdb && \
  ln -s /usr/local/bin/run_in_xilinx_env /usr/local/bin/xsdk && \
  ln -s /usr/local/bin/run_in_xilinx_env /usr/local/bin/xsim && \
  ln -s /usr/local/bin/run_in_xilinx_env /usr/local/bin/xvhdl && \
  ln -s /usr/local/bin/run_in_xilinx_env /usr/local/bin/xvlog
