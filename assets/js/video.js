export const VideoHook = {
    mounted() {
        this.updated();
    },
    updated() {
        const video = document.getElementById("video-preview");
        if (video && video.duration) {
            console.log(video);
            this.el.value = video.duration;
        }
    },
}