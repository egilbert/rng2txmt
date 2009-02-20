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

result_dir="test/Generated Language Grammars"
name=`basename -s .rng $1`;
xml_result="$result_dir/$name.plist.xml"
plist_result="$result_dir/$name.plist"

echo "Generating grammar for $name..."
xsltproc --output "$xml_result" rng2txmt.xsl "$1";
echo "Checking validity..."
plutil -lint "$xml_result";
echo "Generating old style Property List..."
xsltproc --output "$plist_result" xml2plist.xsl "$xml_result";
# FIXME auto indent $xml_result. Indent both fails (it not C) and uses tabs.
echo "Done."
