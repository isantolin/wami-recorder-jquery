#!/bin/sh

mxmlc -compiler.source-path=src -static-link-runtime-shared-libraries=true \
       -output example/client/Wami.swf src/edu/mit/csail/wami/client/Wami.mxml
