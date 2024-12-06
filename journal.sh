python3 -m venv venv_cell_towers
source venv_cell_towers/bin/activate

pip install geopandas ipykernel matplotlib shapely
# pip install psycopg2-binary python-dotenv flask
# pip install tqdm

touch .gitignore
echo "venv*" > .gitignore
echo "key*" >> .gitignore
echo ".env" >> .gitignore
echo "data/" >> .gitignore
echo "z_*" >> .gitignore

touch 1.0.extract.ipynb && code 1.0.extract.ipynb

# https://opencellid.org/

# process the 208.csv.gz file
# exract data from .gz file
cd data
gunzip -k 208.csv.gz

# data exported to data/208.geojson file

gh repo create cell_towers --public --confirm

# rm -rf .git
git init
git branch -M main
git remote add origin https://github.com/yzpt/cell_towers.git
git add .
git commit -m "first commit"
git push --set-upstream origin main


# ===== tippecanoe =========================================
# setup:
# https://github.com/felt/tippecanoe
# sudo apt-get install gcc g++ make libsqlite3-dev zlib1g-dev
# git clone https://github.com/felt/tippecanoe.git
# cd tippecanoe
# make -j
# sudo make install
tippecanoe -v
# 2.71.0
tippecanoe -o data/208.mbtiles -z12 data/208.geojson --force
tippecanoe -o data/208.mbtiles -z12 data/208.geojson --force --drop-densest-as-needed --extend-zooms-if-still-dropping



# ===== tileserver-gl ======================================
# mkdir data
chmod 777 $(pwd)/data
chmod 777 $(pwd)

docker run --rm -it -v $(pwd):/data -p 8080:8080 maptiler/tileserver-gl --file data/208.mbtiles
# http://localhost:8080/data/208/{z}/{x}/{y}.pbf



