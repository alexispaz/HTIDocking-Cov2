version=${1:-27}
echo "Using chembl $version database"

echo "Check if database folder exists or download and extract"
if ! [ -d chembl_${version} ]; then
	
	echo "- Download chembl ${version} sqlite database"
  url="https://ftp.ebi.ac.uk/pub/databases/chembl/ChEMBLdb/releases/chembl_$version"
	file=chembl_${version}_sqlite.tar.gz
	[ -f $file ] || curl -O --insecure "$url/$file"
	
	echo "- Deploying checksums.dat"
	cat > checksums.dat <<-XYZ
	f3e17f0101abd1dab6ec0f0d4e6035f696d797a64bba61d6efe681867a2a1e92  chembl_28_sqlite.tar.gz
	6f23acbfbeae73203594a44e18cc8e770df401aad71265dd3cf895267855d964  chembl_27_sqlite.tar.gz
	6f23acbfbeae73203594a44e18cc8e770df401aad71265dd3cf895267855d964  chembl_26_sqlite.tar.gz
	XYZ
	
	echo "- Verifying checksum of database tarball"
	if ! sha256sum -c <(grep chembl_$version checksums.dat); then
	  echo "Checksum failed" >&2
	  exit 1
	fi
	
	echo "- Extracting database into chembl_${version} folder"
	tar -xvzf chembl_${version}_sqlite.tar.gz 
fi  

echo "Creating output output_${version} folder"
mkdir -p output_${version}
cd output_${version}

echo "Copying data from chembl database into hards.db database"
rm -f hards.db
sqlite3 ../chembl_${version}/chembl_${version}_sqlite/chembl_${version}.db < ../build.sql

echo "Find high active repurpoused drugs (HARDs)"
sqlite3 hards.db < ../hards.sql

echo "Export data into plain text to output_${version} folder"
sqlite3 hards.db < ../extract.sql
