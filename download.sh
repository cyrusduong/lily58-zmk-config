rm *.uf2
gh run watch
gh run download -n firmware

# rename the uf2 to be more easy to work with
mv lily58_left-nice_nano_v2-zmk.uf2 left.uf2
mv lily58_right-nice_nano_v2-zmk.uf2 right.uf2
