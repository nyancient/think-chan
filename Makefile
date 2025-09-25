think-chan: src/model.json src/assets/*/*/*/*.png
	./normalize-images.sh src/assets think-chan/assets
	cp src/model.json think-chan/

.PHONY: clean
clean:
	rm -r think-chan
