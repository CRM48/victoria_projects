const carousel = document.getElementById("carousel");
const images = carousel.querySelectorAll("img");
const imageWidth = 1280;
let index = 0;

// Clone first image and append it to the end to make smooth change between last one and first one
const firstClone = images[0].cloneNode(true);
carousel.appendChild(firstClone);

function moveCarousel() {
  index++;
  carousel.style.transition = "transform 4s ease-in-out";
  carousel.style.transform = `translateX(-${index * imageWidth}px)`;

  if (index === images.length) {
    //disappearance setting
    setTimeout(() => {
      carousel.style.transition = "none";
      carousel.style.transform = "translateX(0px)";
      index = 0;
    }, 4000);
  }
}

setInterval(moveCarousel, 10000);
