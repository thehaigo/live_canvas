let Hooks = {};
Hooks.Canvas = {
  mounted() {
    let canvas = this.el.firstElementChild;
    let context = canvas.getContext("2d");
    let canvas2 = document.getElementById("canvas2");
    let context2 = canvas2.getContext("2d");
    let img = new Image();

    this.handleEvent("draw", (data) => {
      img.src = `data:${data.mime};base64,${data.src}`;
      img.onload = () => {
        let width = img.width < 512 ? img.width : 512;
        let height = img.height < 512 ? img.height : 512;
        canvas.width = width;
        canvas2.width = width;
        canvas.height = height;
        canvas2.height = height;
        context.drawImage(img, 0, 0);
        let pixel = context.getImageData(
          0,
          0,
          canvas.clientWidth,
          canvas.clientHeight
        );
        this.pushEvent("drew", pixel);
      };
    });

    this.handleEvent("remove", () => {
      context.clearRect(0, 0, canvas.width, canvas.height);
      context2.clearRect(0, 0, canvas2.width, canvas2.height);
    });

    this.handleEvent("manipulate", (data) => {
      let imageData = new ImageData(
        new Uint8ClampedArray(data.pixel),
        canvas.clientWidth,
        canvas.clientHeight
      );
      context2.putImageData(imageData, 0, 0);
    });
  },
};

export default Hooks;
