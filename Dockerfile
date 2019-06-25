FROM alpine

COPY nabla.c /
RUN apk add build-base \
    && gcc -o nabla nabla.c \
    && apk del build-base linux-headers pcre-dev openssl-dev && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/nabla"]
CMD ["Bonjour"]
