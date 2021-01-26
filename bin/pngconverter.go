package main

import (
	"bytes"
	"fmt"
	"image"
	"image/png"
	"io/ioutil"
	"log"
	"os"

	"golang.org/x/image/draw"
)

func main() {
	folderOriginal := "isapp\\assets\\pupils\\original\\"
	folderNew := "isapp\\assets\\pupils\\"

	for i := 1; i <= 131; i++ {
		name := fmt.Sprintf("p%03d.png", i)
		log.Printf("%s", name)
		f, err := ioutil.ReadFile(folderOriginal + name)
		if err != nil {
			log.Fatal(err)
		}
		img, err := png.Decode(bytes.NewReader(f))
		if err != nil {
			log.Fatal(err)
		}
		bounds := img.Bounds()
		dst := image.NewRGBA(image.Rect(0, 0, 128, 128))
		draw.CatmullRom.Scale(dst, dst.Bounds(), img, bounds, draw.Over, nil)
		out, err := os.Create(folderNew + name)
		if err != nil {
			log.Fatal(err)
		}
		err = png.Encode(out, dst)
		if err != nil {
			log.Fatal(err)
		}
		out.Close()
	}
}
