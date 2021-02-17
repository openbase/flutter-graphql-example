#!/bin/bash

get-graphql-schema http://demo.basecubeone.org:13781/graphql > bco.schema.json
flutter pub run build_runner build

