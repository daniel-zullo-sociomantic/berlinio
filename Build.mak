override LDFLAGS += -llzo2 -lebtree -lrt
override DFLAGS  += -w -I./submodules/redis/source

$B/berlinio: $C/src/berlinio/main.d

berlinio: $B/berlinio

all += berlinio
