FROM alpine

COPY myhello.c /
RUN apk add build-base \
    && gcc -o myhello2 myhello.c
#    && apk -delete build-base


ENTRYPOINT ["/myhello2"]
CMD ["Bonjour"]
