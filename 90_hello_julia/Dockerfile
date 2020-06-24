FROM julia:1.4.2
LABEL maintainer="fumiya.sato.rop@gmail.com"
LABEL version="0.0.1"
LABEL description="Docker Julia test."

RUN julia -e 'using Pkg; Pkg.add("PyPlot")'

RUN mkdir /src
COPY Bezier_curves.jl /src

CMD [ "julia", "/src/Bezier_curves.jl" ]