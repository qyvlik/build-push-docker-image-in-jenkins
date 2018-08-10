FROM library/alpine

ADD README.md /README.md

CMD ["cat", "/README.md"]
