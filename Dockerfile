FROM alpine

ADD README.md /README.md

CMD ["cat", "/README.md"]
