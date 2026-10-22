FROM accetto/debian-vnc-xfce-chromium-g3:12
ARG FRP_SERVER_ADDR
ARG FRP_CUSTOM_DOMAINS
USER root
ADD frpc.toml /etc/frpc.toml
#RUN apt update && apt install -y curl fastfetch
RUN wget -q https://github.com/fatedier/frp/releases/download/v0.71.1/frp_0.71.1_linux_amd64.tar.gz \
    && tar -xzvf frp*linux_amd64.tar.gz && mv ./frp*linux_amd64/frpc /usr/bin && rm -rf ./frp* \
    && domains_list="" \
    && IFS=','; for domain in ${FRP_CUSTOM_DOMAINS}; do \
        domain_trimmed="$(echo "${domain}" | xargs)"; \
        if [ -n "${domain_trimmed}" ]; then \
          if [ -n "${domains_list}" ]; then domains_list="${domains_list}, "; fi; \
          domains_list="${domains_list}\"${domain_trimmed}\""; \
        fi; \
      done \
    && sed -i "s/serverAddr = \"__FRP_SERVER_ADDR__\"/serverAddr = \"${FRP_SERVER_ADDR}\"/" /etc/frpc.toml \
    && sed -i "s/customDomains = \[\"__FRP_CUSTOM_DOMAINS__\"\]/customDomains = [${domains_list}]/" /etc/frpc.toml \
    && unset IFS \
    && \
    sed -i "3i\frpc -c /etc/frpc.toml >/dev/null 2>&1 &" /dockerstartup/startup.sh
