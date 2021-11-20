let Hooks = {};
Hooks.Canvas = {
  mounted() {
    let canvas = this.el.firstElementChild;
    let context = canvas.getContext("2d");
    let canvas2 = document.getElementById("canvas2");
    let ctx = canvas2.getContext("2d");
    let img = new Image();

    this.handleEvent("draw", (path) => {
      img.src = `data:image/jpg;base64,${path.src}`;
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
      };
    });

    this.handleEvent("remove", () => {
      context.clearRect(0, 0, canvas.width, canvas.height);
      ctx.clearRect(0, 0, canvas2.width, canvas2.height);
    });
  },
};

export default Hooks;
