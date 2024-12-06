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

# https://github.com/mapbox/tippecanoe/issues/512
# https://github.com/felt/tippecanoe?tab=readme-ov-file#dropping-a-fixed-fraction-of-features-by-zoom-level
tippecanoe -o data/208.mbtiles -z12 data/208.geojson --force -B0 --drop-densest-as-needed --extend-zooms-if-still-dropping
tippecanoe -o data/208.mbtiles -z12 data/208.geojson --force -B0
# no
tippecanoe -o data/208.mbtiles -z7 -Z4 data/208.geojson --force -B4 --maximum-tile-bytes=5000000 --maximum-tile-features=10000000
tippecanoe -o data/208.mbtiles -z7 -Z4 data/208.geojson --force -r1 --maximum-tile-bytes=5000000 --maximum-tile-features=1000000 --drop-fraction-as-needed
tippecanoe -o data/208.mbtiles -z16 -Z5 data/208.geojson --force -r1 --maximum-tile-bytes=50000000 --maximum-tile-features=10000000
tippecanoe -o data/208.mbtiles -z12 -Z2 data/208_light.geojson --force -B4 -r1 --maximum-tile-bytes=50000000 --maximum-tile-features=10000000 -al
tippecanoe -o data/208.mbtiles -z16 data/208_light.geojson --force -Bg -rg --maximum-tile-bytes=50000000 --maximum-tile-features=10000000 -al

tippecanoe -o data/208.mbtiles -z16 -Z5 data/208_light.geojson --force -Bg -r1 -al -as --maximum-tile-bytes=50000000 --maximum-tile-features=10000000 
# try --extend-zooms-if-still-dropping:
tippecanoe -o data/208.mbtiles -z16 -Z5 data/208_light.geojson --force -Bg -r1 -al -as --maximum-tile-bytes=50000000 --maximum-tile-features=10000000 --extend-zooms-if-still-dropping
# no

# observatoire ANFR
tippecanoe -o data/obs_light.mbtiles -z16 -Z5 data/obs_light.geojson -B8 -r1 -al -as --maximum-tile-bytes=50000000 --maximum-tile-features=10000000 --force
# trop de points à low zoom levels
docker run --rm -it -v $(pwd):/data -p 8080:8080 maptiler/tileserver-gl --file data/obs_light.mbtiles

tippecanoe -o data/obs_light.mbtiles -z16 data/obs_light.geojson -B5 -r1 -as --force



# ===== tileserver-gl ======================================
# mkdir data
chmod 777 $(pwd)/data
chmod 777 $(pwd)

docker run --rm -it -v $(pwd):/data -p 8080:8080 maptiler/tileserver-gl --file data/208.mbtiles
# http://localhost:8080/data/208/{z}/{x}/{y}.pbf



npm install dotenv express
node server.js