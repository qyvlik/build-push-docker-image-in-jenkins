FROM alpine

ADD README.md /README.md

CMD ["echo", "/README.md"]
