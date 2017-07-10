override LDFLAGS += -llzo2 -lebtree -lrt
#--no-as-needed -lssl -lcrypto -lanl

override DFLAGS  += -w -I./submodules/redis/source \
-I./submodules/vibe-core/source \
-I./submodules/eventcore/source \
-I./submodules/taggedalgebraic/source \
-I./submodules/vibe.d/inet \
-I./submodules/vibe.d/internal \
-I./submodules/vibe.d/textfilter \
-I./submodules/vibe.d/utils \
-I./submodules/vibe.d/stream \
-I./submodules/vibe.d/redis \
-version=VibeCustomMain -version=EventcoreEpollDriver \
-version=Have_vibe_d_redis -version=Have_vibe_d_http -version=Have_diet_ng \
-version=Have_vibe_d_crypto -version=Have_vibe_d_core -version=Have_vibe_core \
-version=Have_eventcore -version=Have_taggedalgebraic \
-version=Have_vibe_d_data -version=Have_vibe_d_utils -version=Have_vibe_d_diet \
-version=Have_vibe_d_stream -version=Have_openssl \
-version=Have_vibe_d_textfilter -version=Have_vibe_d_inet -version=Have_vibe_d_internal

$B/berlinio: $C/src/berlinio/main.d

berlinio: $B/berlinio

all += berlinio
