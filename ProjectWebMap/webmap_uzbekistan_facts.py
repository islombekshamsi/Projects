import folium
import pandas

map1 = folium.Map(location=[41.296786, 69.236795])
fgm = folium.FeatureGroup(name="Mountains")
data = pandas.read_csv("uz_mountains.txt")


def color_producer(elevation):
    if elevation < 3500:
        return 'green'
    elif 3500 < elevation < 4500:
        return 'orange'
    else:
        return 'red'


lat = list(data['LAT'])
lon = list(data['LON'])
elev = list(data['ELEV'])
names = list(data['NAME'])

for lt, ln, el, ns in zip(lat, lon, elev, names):
    fgm.add_child(folium.CircleMarker(location=[lt, ln], radius=6,
                                      popup=ns + "'s elevation: "+str(el) + " metres", fill_color=color_producer(el),
                                      color='black', fill_opacity=1.0))

fgp = folium.FeatureGroup(name="Population")
fgp.add_child(folium.GeoJson(data=open("world.json", 'r', encoding='utf-8-sig').read(),
                            style_function=lambda x: {'fillColor': 'green' if x['properties']['POP2005'] < 10_000_000
                            else 'orange' if 10_000_000 < x['properties']['POP2005'] < 200_000_000
                            else 'red'}))


def color_depth(depth):  # lightblue
    if depth > 500:
        return 'blue'
    elif 200 < depth < 500:
        return 'blue'
    else:
        return 'lightblue'


fgl = folium.FeatureGroup(name="Lakes")
data = pandas.read_csv("uz_lakes.txt")
lat = list(data['LAT'])
lon = list(data['LON'])
depth = list(data['DEPTH'])
names = list(data['NAME'])
for lt, ln, dp, ns in zip(lat, lon, depth, names):
    fgl.add_child(folium.CircleMarker(location=[lt, ln], radius=6,
                                      popup=ns + "'s depth: "+str(dp) + ' metres', fill_color=color_depth(dp),
                                      color='black', fill_opacity=1.0))

map1.add_child(fgm)
map1.add_child(fgl)
map1.add_child(fgp) # Turn population off to see info about circle markers.
map1.add_child(folium.LayerControl())
map1.save("Map.html")
