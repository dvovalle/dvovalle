# https://auth0.com/blog/image-processing-in-python-with-pillow/

from PIL import Image

__DIR_IMG: str = '/home/danilo/GitHub/dvovalle/testes/img'

def processo(img_name: str) -> None:
    image = Image.open(img_name)
    new_image = image.resize((400, 400))
    new_image.save(f'{__DIR_IMG}/image_400.jpg')

    print(image.size)
    print(new_image.size)

if __name__=='__main__':  
    processo(img_name= f'{__DIR_IMG}/img01.jpg')
