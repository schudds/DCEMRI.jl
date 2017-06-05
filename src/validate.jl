using PyPlot

function analyze6(mat::Dict, outdir::AbstractString; dx=1, makeplots=true)

  R1map = mat["R10"]
  S0map = mat["S0"]
  modelmap = mat["modelmap"]
  Ct = mat["Ct"]
  Kt = mat["Kt"]
  ve = mat["ve"]
  vp = mat["vp"]
  resid = mat["resid"]
  q = quantile(S0map[:], 0.99)
  S0map[S0map .> q] = q
  back = (S0map - minimum(S0map)) / (maximum(S0map) - minimum(S0map))
  mask = convert(Array{Bool,2}, mat["mask"])

  # compare to known truths
  u = ones(div(10,dx),div(10,dx))
  Kt_truth = repmat([0.01*u; 0.02*u; 0.05*u; 0.1*u; 0.2*u; 0.35*u], 1, 5)
  ve_truth = repmat([0.01*u; 0.05*u; 0.1*u; 0.2*u; 0.5*u]', 6, 1)

  Kt_error = clamp.(100.0*(Kt - Kt_truth) ./ (Kt_truth + eps()), -100.0, 100.0)
  ve_error = clamp.(100.0*(ve - ve_truth) ./ (ve_truth + eps()), -100.0, 100.0)
  print_with_color(:green, "Kt\n\tRMSE:\t$(sqrt(norm(Kt_error)^2 / length(Kt_error))) %\n")
  print_with_color(:green, "\terrmax:\t$(maximum(abs.(Kt_error)))\n")
  print_with_color(:green, "\tCCC:\t$(ccc(Kt_truth, Kt))\n")
  print_with_color(:green, "ve\n\tRMSE:\t$(sqrt(norm(ve_error)^2 / length(ve_error))) %\n")
  print_with_color(:green, "\terrmax:\t$(maximum(abs.(ve_error)))\n")
  print_with_color(:green, "\tCCC:\t$(ccc(ve_truth, ve))\n")

  if !makeplots
    return
  end

  ytpos = collect((0+floor(Integer, 5/dx)):div(10,dx):(div(60,dx)-1))
  xtpos = collect((0+floor(Integer, 5/dx)):div(10,dx):(div(50,dx)-1))
  ytlabels = [string(x) for x in [0.01,0.02,0.05,0.1,0.2,0.35]]
  xtlabels = [string(x) for x in [0.01,0.05,0.1,0.2,0.5]]

  println("Plotting results ...")
  # AIF
  figure(figsize=(4.5,4.5))
  clf()
  plot(mat["t"], mat["Cp"], "ko-")
  xlabel("time (min)")
  # yticks([0:2:10]) # This produces an error
  ylim(0,10)
  ylabel("[Gd-DTPA] (mM)")
  title("arterial input function, \$C_p\$")
  savefig("$outdir/aif.pdf")

  figure(figsize=(4.5, 4.5))
  clf()
  imshow(modelmap, interpolation="nearest", cmap="cubehelix")
  title("model used")
  xticks(xtpos, xtlabels)
  yticks(ytpos, ytlabels)
  xlabel("\$v_\\mathrm{e}\$")
  ylabel("\$K^\\mathrm{trans}\$")
  colorbar(ticks=[0,1,2,3])
  savefig("$outdir/modelmap.pdf",bbox_inches="tight")

  # PARAMETER MAPS
  figure(figsize=(4.5, 4.5))
  clf()
  imshow(Kt, interpolation="nearest", cmap="cubehelix", vmin=0, vmax=0.35)
  title("\$K^\\mathrm{trans}\$ (min\$^{-1}\$)")
  xticks(xtpos, xtlabels)
  yticks(ytpos, ytlabels)
  xlabel("\$v_\\mathrm{e}\$")
  ylabel("\$K^\\mathrm{trans}\$")
  colorbar(ticks=[0.1,0.2,0.3,0.4])
  savefig("$outdir/Kt.pdf",bbox_inches="tight")

  figure(figsize=(4.5, 4))
  clf()
  imshow(ve, interpolation="nearest", cmap="cubehelix", vmin=0, vmax=0.6)
  title("\$v_\\mathrm{e}\$")
  colorbar(ticks=[0:6]/10.0)
  xticks(xtpos, xtlabels)
  yticks(ytpos, ytlabels)
  xlabel("\$v_\\mathrm{e}\$")
  ylabel("\$K^\\mathrm{trans}\$")
  savefig("$outdir/ve.pdf",bbox_inches="tight")

  figure(figsize=(4.5, 4))
  clf()
  imshow(resid, interpolation="nearest", cmap="cubehelix", vmin=0)
  title("residual")
  colorbar()
  xticks(xtpos, xtlabels)
  yticks(ytpos, ytlabels)
  xlabel("\$v_\\mathrm{e}\$")
  ylabel("\$K^\\mathrm{trans}\$")
  savefig("$outdir/resid.pdf",bbox_inches="tight")

  figure(figsize=(4.5, 4))
  clf()
  m = maximum(abs.(Kt_error))
  imshow(Kt_error, interpolation="nearest", cmap="PiYG", vmin=-m, vmax=m)
  title("% error in \$K^\\mathrm{trans}\$")
  xticks(xtpos, xtlabels)
  yticks(ytpos, ytlabels)
  xlabel("\$v_\\mathrm{e}\$")
  ylabel("\$K^\\mathrm{trans}\$")
  colorbar()
  savefig("$outdir/Kt_error.pdf",bbox_inches="tight")

  figure(figsize=(4.5, 4))
  clf()
  m = maximum(abs.(ve_error))
  imshow(ve_error, interpolation="nearest", cmap="PiYG", vmin=-m, vmax=m)
  title("% error in \$v_\\mathrm{e}\$")
  xticks(xtpos, xtlabels)
  yticks(ytpos, ytlabels)
  xlabel("\$v_\\mathrm{e}\$")
  ylabel("\$K^\\mathrm{trans}\$")
  colorbar()
  savefig("$outdir/ve_error.pdf",bbox_inches="tight")
end



function analyze4(mat::Dict, outdir::AbstractString; dx=1, makeplots=true)
  R1map = mat["R10"]
  S0map = mat["S0"]
  modelmap = mat["modelmap"]
  Ct = mat["Ct"]
  Kt = mat["Kt"]
  ve = mat["ve"]
  vp = mat["vp"]
  resid = mat["resid"]
  q = quantile(S0map[:], 0.99)
  S0map[S0map .> q] = q
  back = (S0map - minimum(S0map)) / (maximum(S0map) - minimum(S0map))
  mask = convert(Array{Bool,2}, mat["mask"])

  # compare to known truths
  u = ones(div(180,dx),div(10,dx))
  Kt_truth = hcat(0.01u, 0.02u, 0.05u, 0.1u, 0.2u)

  u = ones(div(10,dx),div(50,dx))
  u = vcat(0.1u, 0.2u, 0.5u)
  ve_truth = vcat(u, u, u, u, u, u)

  u = ones(div(30,dx),div(50,dx))
  vp_truth = vcat(0.001u, 0.005u, 0.01u, 0.02u, 0.05u, 0.1u)

  Kt_error = clamp.(100.0*(Kt - Kt_truth) ./ (Kt_truth + eps()), -100.0, 100.0)
  ve_error = clamp.(100.0*(ve - ve_truth) ./ (ve_truth + eps()), -100.0, 100.0)
  vp_error = clamp.(100.0*(vp - vp_truth) ./ (vp_truth + eps()), -100.0, 100.0)
  print_with_color(:green, "Kt\n\tRMSE:\t$(sqrt(norm(Kt_error)^2 / length(Kt_error))) %\n")
  print_with_color(:green, "\terrmax:\t$(maximum(abs.(Kt_error))) %\n")
  print_with_color(:green, "\tCCC:\t$(ccc(Kt_truth, Kt))\n")
  print_with_color(:green, "ve\n\tRMSE:\t$(sqrt(norm(ve_error)^2 / length(ve_error))) %\n")
  print_with_color(:green, "\terrmax:\t$(maximum(abs.(ve_error))) %\n")
  print_with_color(:green, "\tCCC:\t$(ccc(ve_truth, ve))\n")
  print_with_color(:green, "vp\n\tRMSE:\t$(sqrt(norm(vp_error)^2 / length(vp_error))) %\n")
  print_with_color(:green, "\terrmax:\t$(maximum(abs.(vp_error))) %\n")
  print_with_color(:green, "\tCCC:\t$(ccc(vp_truth, vp))\n")

  if !makeplots
    return
  end

  ytpos = collect((div(10,dx)+floor(Integer, 5/dx)):div(30,dx):(div(180,dx)-1))
  xtpos = collect((0+floor(Integer, 5/dx)):div(10,dx):(div(50,dx)-1))
  ytlabels = [string(x) for x in [0.001, 0.005, 0.01, 0.02, 0.05, 0.1]]
  xtlabels = [string(x) for x in [0.01,0.02,0.05,0.1,0.2]]

  println("Plotting results ...")
  # AIF
  figure(figsize=(4,4))
  clf()
  plot(mat["t"], mat["Cp"], "ko-")
  xlabel("time (min)")
  #yticks([0:10])
  ylabel("[Gd-DTPA] (mM)")
  title("arterial input function, \$C_p\$")
  savefig("$outdir/aif.pdf",bbox_inches="tight")

  figure(figsize=(3.5, 6))
  clf()
  imshow(modelmap, interpolation="nearest", cmap="cubehelix")
  title("model used")
  xticks(xtpos, xtlabels, fontsize=8)
  yticks(ytpos, ytlabels)
  xlabel("\$K^\\mathrm{trans}\$")
  ylabel("\$v_\\mathrm{p}\$")
  colorbar(ticks=[0,1,2,3])
  savefig("$outdir/modelmap.pdf",bbox_inches="tight")

  # PARAMETER MAPS
  figure(figsize=(3.5, 6))
  clf()
  imshow(Kt, interpolation="nearest", cmap="cubehelix", vmin=0, vmax=0.2)
  title("\$K^\\mathrm{trans}\$ (min\$^{-1}\$)")
  xticks(xtpos, xtlabels, fontsize=8)
  yticks(ytpos, ytlabels)
  xlabel("\$K^\\mathrm{trans}\$")
  ylabel("\$v_\\mathrm{p}\$")
  colorbar()
  savefig("$outdir/Kt.pdf",bbox_inches="tight")

  figure(figsize=(3.5, 6))
  clf()
  imshow(ve, interpolation="nearest", cmap="cubehelix", vmin=0, vmax=0.6)
  title("\$v_e\$")
  xticks(xtpos, xtlabels, fontsize=8)
  yticks(ytpos, ytlabels)
  xlabel("\$K^\\mathrm{trans}\$")
  ylabel("\$v_\\mathrm{p}\$")
  colorbar()
  savefig("$outdir/ve.pdf",bbox_inches="tight")

  figure(figsize=(3.5, 6))
  clf()
  imshow(vp, interpolation="nearest", cmap="cubehelix", vmin=0, vmax=0.12)
  title("\$v_p\$")
  xticks(xtpos, xtlabels, fontsize=8)
  yticks(ytpos, ytlabels)
  xlabel("\$K^\\mathrm{trans}\$")
  ylabel("\$v_\\mathrm{p}\$")
  colorbar()
  savefig("$outdir/vp.pdf",bbox_inches="tight")

  figure(figsize=(3.5, 6))
  clf()
  imshow(resid, interpolation="nearest", cmap="cubehelix", vmin=0)
  title("residual")
  xticks(xtpos, xtlabels, fontsize=8)
  yticks(ytpos, ytlabels)
  xlabel("\$K^\\mathrm{trans}\$")
  ylabel("\$v_\\mathrm{p}\$")
  colorbar()
  savefig("$outdir/resid.pdf",bbox_inches="tight")


  figure(figsize=(3.5, 6))
  clf()
  m = maximum(abs.(Kt_error))
  imshow(Kt_error, interpolation="nearest", cmap="PiYG", vmin=-m, vmax=m)
  title("% error in \$K^\\mathrm{trans}\$")
  xticks(xtpos, xtlabels, fontsize=8)
  yticks(ytpos, ytlabels)
  xlabel("\$K^\\mathrm{trans}\$")
  ylabel("\$v_\\mathrm{p}\$")
  colorbar()
  savefig("$outdir/Kt_error.pdf",bbox_inches="tight")

  figure(figsize=(3.5, 6))
  clf()
  m = maximum(abs.(ve_error))
  imshow(ve_error, interpolation="nearest", cmap="PiYG", vmin=-m, vmax=m)
  title("% error in \$v_e\$")
  xticks(xtpos, xtlabels, fontsize=8)
  yticks(ytpos, ytlabels)
  xlabel("\$K^\\mathrm{trans}\$")
  ylabel("\$v_\\mathrm{p}\$")
  colorbar()
  savefig("$outdir/ve_error.pdf",bbox_inches="tight")

  figure(figsize=(3.5, 6))
  clf()
  m = maximum(abs.(vp_error))
  imshow(vp_error, interpolation="nearest", cmap="PiYG", vmin=-m, vmax=m)
  title("% error in \$v_p\$")
  xticks(xtpos, xtlabels, fontsize=8)
  yticks(ytpos, ytlabels)
  xlabel("\$K^\\mathrm{trans}\$")
  ylabel("\$v_\\mathrm{p}\$")
  colorbar()
  savefig("$outdir/vp_error.pdf",bbox_inches="tight")
end

function analyze(n, mat::Dict, outdir::AbstractString; kwargs...)
  if n == 4
    analyze4(mat, outdir; kwargs...)
  elseif n == 6
    analyze6(mat, outdir; kwargs...)
  end
end


function validate(n, outdir::AbstractString; kwargs...)
  @assert n == 4 || n == 6 "n must be 4 or 6"
  cd(Pkg.dir("DCEMRI/test/q$n"))

  println("Running analysis of noise-free QIBA v$n data ...")
  isdir("$outdir/results") || mkdir("$outdir/results")
  results = fitdata(datafile="qiba$n.mat",outfile="$outdir/results/results.mat")
  analyze(n, results, "$outdir/results", dx=10; kwargs...)

  println("Running analysis of noisy QIBA v$n data ...")
  isdir("$outdir/results_noisy") || mkdir("$outdir/results_noisy")
  results = fitdata(datafile="qiba$(n)noisy.mat",
                     outfile="$outdir/results_noisy/results.mat")

  analyze(n, results, "$outdir/results_noisy"; kwargs...)
  println("Validation complete. Results can be found in $outdir.")
end

validate(n; kwargs...) = validate(n, Pkg.dir("DCEMRI/test/q$n"); kwargs...)
function validate(kwargs...)
  validate(6; kwargs...)
  validate(4; kwargs...)
end
