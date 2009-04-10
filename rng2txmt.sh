#!/bin/sh

if test $# -ne 1
then
  echo 1>&2 Usage: $0 file.rng
  exit 127
fi

if test ! -f $1
then
  echo 1>&2 Error: $1 does not exist or is not a regular file.
  exit 127
fi

base_dir="."
source_dir="$base_dir/src"
result_dir="$base_dir/Generated Language Grammars"
name=`basename -s .rng $1`;
xml_result="$result_dir/$name.plist.xml"
plist_result="$result_dir/$name.plist"
rng2txmt_transform="$source_dir/rng2txmt.xsl"
xml2plist_transform="$source_dir/xml2plist.xsl"

echo "Generating grammar for $name..."
xsltproc --output "$xml_result" "$xsl_transform" "$1";
echo "Checking validity of XML Property List..."
plutil -lint "$xml_result";
echo "Generating old style Property List..."
# FIXME auto indent $plist_result.
xsltproc --output "$plist_result" "$xml2plist_transform" "$xml_result";
echo "Done."
