# Wallpaper collection

The active default remains `wallpaper.jpg`. Every other file here takes part in
the rotation that `scripts/wallpaper-daemon.sh` cycles through; a single image
can also be pinned with `scripts/wallpaper.sh /path/to/image`.

The list is read straight from this directory by `hosts/desktop/home.nix`, so
adding a painting is just a matter of dropping the file in. Give it a name
containing a dash so the daemon picks it up (`wallpaper.jpg` has no dash, which
is what keeps it as the default), and add an attribution line below.

## Public-domain paintings

- `tani-buncho-blue-green-landscape.jpg` — [A bluegreen landscape by Tani Buncho](https://commons.wikimedia.org/wiki/File:A_bluegreen_landscape_by_Tani_Buncho.jpg), Wikimedia Commons. A tall blue-green landscape that works well on a portrait monitor or with `swaybg -m fill`.
- `saal-forest-landscape-moonlight.jpg` — [Forest Landscape in the Moonlight](https://commons.wikimedia.org/wiki/File:Forest_Landscape_in_the_Moonlight_by_Georg_Eduard_Otto_Saal_Rijksmuseum_Amsterdam_SK-A-1827.jpg) by Georg Eduard Otto Saal, Wikimedia Commons. Dark forest tones and warm moonlight complement Everforest green and yellow.
- `bierstadt-mountainous-landscape-moonlight.jpg` — [Mountainous Landscape by Moonlight (1871)](https://commons.wikimedia.org/wiki/File:Mountainous_Landscape_by_Moonlight_1871_Albert_Bierstadt.jpg) by Albert Bierstadt, Wikimedia Commons. A wide blue-green mountain scene suited to a widescreen desktop.
- `ryder-moonlight-marine.jpg` — [Moonlight Marine](https://commons.wikimedia.org/wiki/File:Moonlight_Marine_MET_DT240273.jpg) by Albert Pinkham Ryder, The Metropolitan Museum of Art, Wikimedia Commons. A near-square sea nocturne; the most minimal of the group, with a low horizon and a lot of dark water.
- `ryder-moonlit-cove.jpg` — [Moonlit Cove](https://commons.wikimedia.org/wiki/File:Albert_Pinkham_Ryder_-_Moonlit_Cove_-_Google_Art_Project.jpg) (1880) by Albert Pinkham Ryder, Wikimedia Commons. Heavy impasto and thick impasto highlights along the surf, the warmest of the Ryder pair.
- `ryder-sailing-by-moonlight.jpg` — [Sailing by Moonlight](https://commons.wikimedia.org/wiki/File:Albert_Pinkham_Ryder_-_Sailing_by_Moonlight_-_Google_Art_Project.jpg) by Albert Pinkham Ryder, Wikimedia Commons. A tall-format nocturne with a moon behind cloud and a single vessel, the best of the set for a portrait display.
- `van-der-neer-moonlit-landscape-with-bridge.jpg` — [Moonlit Landscape with Bridge](https://commons.wikimedia.org/wiki/File:Van_der_Neer_-_Moonlit_Landscape_with_Bridge.jpg) by Aert van der Neer (c. 1648–1660s), National Gallery of Art, Wikimedia Commons. A river town under a full moon, the brightest and most detailed of the Dutch group.
- `van-der-neer-new-amstel-river-moonlight.jpg` — [Moonlit Landscape with a View of the New Amstel River and Castle Kostverloren](https://commons.wikimedia.org/wiki/File:Aert_van_der_Neer_-_Moonlit_Landscape_with_a_View_of_the_New_Amstel_River_and_Castle_Kostverloren_-_Google_Art_Project.jpg) (1647) by Aert van der Neer, J. Paul Getty Museum, Wikimedia Commons. A wide, densely lit river panorama and the highest resolution file in the collection.
- `van-der-neer-moonlight-landscape-yale.jpg` — [Moonlight Landscape](https://commons.wikimedia.org/wiki/File:Aert_van_der_Neer_-_Moonlight_Landscape_-_1952.44.1_-_Yale_University_Art_Gallery.jpg) by Aert van der Neer, Yale University Art Gallery, Wikimedia Commons. A restrained river scene, mostly shadow, which sits well against a dark UI.

The Commons pages identify these works as public-domain art, public-domain
reproductions, or CC0. Licenses were checked against each file's own Commons
page at download time; keep the source links with the files if the images are
redistributed.

Files are stored at up to 2560px on the long edge and were chosen to stay at or
above 1920px wide, so they hold up on a 1440p desktop without visible softness.
`van-der-neer-moonlight-landscape-yale.jpg` is the narrowest of the set.

## Selecting one

```sh
./scripts/wallpaper.sh wallpapers/saal-forest-landscape-moonlight.jpg
./scripts/wallpaper.sh --list
```

`wallpaper.sh` writes `wallpaper_backup_<timestamp>.jpg` next to the old default
when it replaces `wallpaper.jpg`. Those backups are not part of the collection:
they are skipped by the daemon and ignored by the Home Manager link list, so
they can be deleted at any time.
