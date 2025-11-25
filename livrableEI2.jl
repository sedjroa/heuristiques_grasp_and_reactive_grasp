# ============================================================
# livrableEI2.jl
# Auteurs : Amos GANDONOU
# Objectif : Métaheuristique GRASP, ReactiveGRASP et extensions
# ============================================================
include("src/loadSPP.jl")
include("src/graspSPP.jl")
include("src/kpexchange.jl")
include("src/rgraspSPP.jl")
include("src/graspGraphics.jl")

using Plots
# Se placer dans ce dossier automatiquement
const PROJECT_DIR = @__DIR__
cd(PROJECT_DIR)
println("Dossier de travail : ", PROJECT_DIR)

function resoudreSPP(fname, m, max_iter, alpha)
    
    println("\nInstance: $fname")

    C, A = loadSPP(fname)
    println("Méthode GRASP")
    start_time = time()
    z_grasp = graspSPP(C,A,alpha)
    g_time = round(time() - start_time, digits=2)
    println("Z=$z_grasp |  in ", g_time, " seconds")    
    println("Méthode ReactiveGRASP")
    start_time = time()
    rgraspSPP(C, A, m, max_iter)
    rg_time = round(time() - start_time, digits=2)
    println(" in ", rg_time, " seconds")  

    println("Visualisations Résultats Contraintes Temps")
    graphics(C,A, 60, 10, alpha, fname)
end

function  experimentationSPP(k, max_iter=10, alpha=0.6)
    println("\nLoading...")
    target = "./dat"
    fnames = readdir(target)
    
    for fname in fnames
        resoudreSPP(joinpath(target, fname), k, max_iter, alpha)
    end
end

function graphics(C,A, cs_time=60, update_time=10, alpha=0.6, save_dir=fname)
        save_dir = split(save_dir, ['/', '\\'])[end]
        println("... GRASP Viz ... ")
        zs = grasp_timed(C, A, cs_time, update_time, alpha)
        heuristicPlots(save_dir, zs)
        println("... ReactiveGRASP Viz ... ")
        zsr = rgrasp_timed(C, A)
        heuristicPlots(splitext(save_dir)[1], zsr)
end