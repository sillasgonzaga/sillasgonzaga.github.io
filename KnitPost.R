#Function to publish a R code into github

KnitPost <- function(input, base.url = "/") {
  require(knitr)
  opts_knit$set(base.url = base.url)
  fig.path <- paste0("figs/", sub(".Rmd$", "", basename(input)), "/")
  opts_chunk$set(fig.path = fig.path)
  opts_chunk$set(fig.cap = "center")
  render_jekyll()
  output.file <- tools::file_path_sans_ext(basename(input))
  current.time <- as.character(Sys.Date())
  output.file <- paste0(current.time,  "-", output.file, ".md")
  output.file <- paste0(dirname(input), "/", output.file)
  knit(input, output = output.file, envir = parent.frame())
}


KnitPost("/home/sillas/R/Projetos/PaixaoPorDados/rmd files/sensacionalista-pt01.Rmd")