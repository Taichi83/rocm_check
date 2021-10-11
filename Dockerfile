# Build: sudo docker build -t <project_name> .
# Run: sudo docker run -v $(pwd):/workspace/project --gpus all -it --rm <project_name>


FROM rocm/pytorch:latest


# Deal with pesky Python 3 encoding issue
ENV LANG C.UTF-8
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive


# Basic setup
RUN apt update
RUN apt install -y bash \
                   build-essential \
                   git \
                   curl \
                   ca-certificates \
                   wget \
                   && rm -rf /var/lib/apt/lists

RUN apt-get update && \
    apt-get -y install aria2 git unzip python3-venv netbase && \
    rm -rf /var/lib/apt/lists/*


# Set working directory
WORKDIR /workspace/project




# Install Miniconda and create main env
#ADD https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh miniconda3.sh
#RUN /bin/bash miniconda3.sh -b -p /conda \
#    && echo export PATH=/conda/bin:$PATH >> .bashrc \
#    && rm miniconda3.sh
#ENV PATH="/conda/bin:${PATH}"
#RUN conda create -n ${CONDA_ENV_NAME} python=${PYTHON_VERSION}


USER root
RUN mkdir /code
WORKDIR /code

RUN apt-get update -y && apt-get upgrade -y

RUN pip install -U pip
COPY requirements.txt /code/requirements.txt
RUN pip install -r /code/requirements.txt
RUN pip install -U jedi==0.17.2

## install pytorch
#RUN pip3 install torch torchvision==0.10.0 -f https://download.pytorch.org/whl/rocm4.2/torch_stable.html
# RUN pip install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html
RUN pip install pytorch-lightning torchsummary torchinfo lightning-bolts
#RUN pip install kornia
#RUN pip install --extra-index-url https://developer.download.nvidia.com/compute/redist --upgrade nvidia-dali-cuda110
#RUN pip install botorch
#RUN pip install numpyro[cuda111] -f https://storage.googleapis.com/jax-releases/jax_releases.html
RUN pip install hydra-core --upgrade
RUN pip install hydra-optuna-sweeper --upgrade

#RUN pip install -U ray
## add on Sep 7
#RUN pip install hydra-optuna-sweeper --upgrade

USER root
RUN mkdir /src
RUN mkdir /dataset
WORKDIR /src
RUN chmod -R a+w .