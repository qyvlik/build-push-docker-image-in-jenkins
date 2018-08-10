FROM library/alpine:latest

ADD README.md /README.md

CMD ["cat", "/README.md"]
