FROM pypy:3.11-7.3.19-bookworm

ENV PATH="/usr/bin:/usr/local/bin:$PATH"
ENV LANG=C.UTF-8
ENV LANGUAGE=en_US:
ENV TZ=Asia/Tokyo

# 諸々のインストール
# gmpy2 用に gmp, mpfr, mpc をインストールする
RUN apt-get update -qq \
 && apt-get install -qq \
    zsh time tree git curl nano vim ca-certificates \
    nodejs npm rustc python3-venv python3-pip python3-launchpadlib gfortran pkg-config \
    libgmp-dev libmpfr-dev libmpc-dev libopenblas-dev liblapack-dev libgeos-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Python, PyPy のパッケージをインストール
WORKDIR /tmp
COPY requirements-cpython.txt /tmp/requirements-cpython.txt
RUN python3 -m pip install --no-cache-dir --break-system-packages --upgrade pip \
 && python3 -m pip install --no-cache-dir --break-system-packages -r requirements-cpython.txt

COPY requirements-pypy.txt /tmp/requirements-pypy.txt
RUN pypy3 -m pip install --no-cache-dir --upgrade pip \
&& pypy3 -m pip install --no-cache-dir --config-settings --confirm-license= -r requirements-pypy.txt

# npm (textlint & Task)
RUN npm i -g textlint \
    textlint-rule-preset-ja-technical-writing \
    textlint-rule-preset-ja-spacing \
    textlint-filter-rule-comments \
    textlint-filter-rule-allowlist \
    @go-task/cli && \
    npm cache clean --force

# ac-library のインストール
RUN git clone https://github.com/atcoder/ac-library.git /lib/ac-library
ENV CPLUS_INCLUDE_PATH="/lib/ac-library:/lib/testlib:$CPLUS_INCLUDE_PATH"

# Zsh をいい感じにする
# RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
# COPY zshrc /root/.zshrc

# プロンプトの見た目をいい感じにする
# RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes \
#  && echo "eval \"\$(starship init zsh)\"" >> /root/.zshrc

# シェルを zsh にする
# RUN chsh -s /bin/zsh

# CMD /bin/zsh -c "cd /root/app && exec /bin/zsh"
CMD /bin/bash -c "cd /root/app && exec /bin/bash"
