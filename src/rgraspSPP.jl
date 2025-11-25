include("graspSPP.jl")
using  Statistics

function rgraspSPP(C, A, m=6, max_iter=30)

    the_zs = Dict("$i" => [] for i in 1:m)
    alphas = range(start=0, stop=1, length=m)
    Memory = [0.0 for i in 1:m]
    
    #= GRASP Nalpha itérations pour chaque Alpha =#
    for i in 1:max_iter
        for (j, alpha) in enumerate(alphas)
            z = graspSPP(C, A, alpha)
            push!(the_zs["$j"], z)
            if z > Memory[j]
                Memory[j] = z
            end
        end
        
        if(i % 10 == 0)  ## Mise à jour à chaque 10 itérations
             #= ZBest and ZWorst  =#
            z_best, z_worst = maximum(vcat(values(the_zs)...)), minimum(vcat(values(the_zs)...))

            #= Evaluation of the Qk =#
            q = []
            for i in 1:length(alphas)
                z_avg = mean(the_zs["$i"])
                z_centered = (z_avg - z_worst) / (z_best - z_worst)
                push!(q, z_centered)
            end

            #= Evaluation of que Pk probabilities =#
            p = []
            q_sum = sum(q)
            for qi in q
                push!(p, qi / q_sum)
            end

            ## Mise à jour de la mémoire
            the_zs = Dict("$i" => [] for i in 1:m)

            # Selection du meilleur alpha
            k = argmax(p)
            alpha = alphas[k]
            qk = q[k] 
            pk = p[k]
            zk_best = Memory[k]
            println("Itération $i : Sélection de alpha = ", round(alpha, digits=2), 
                    " avec Pk = ", round(pk, digits=2), 
                    ", Qk = ", round(qk, digits=2), 
                    " et Z_best = ", zk_best)
        end
   
    end
end

# function rgrasp_timed(C, A, m=6, duration=60.0)
#     the_zs = Dict("$i" => [] for i in 1:m)
#     alphas = range(start=0, stop=1, length=m)
#     Memory = [0.0 for _ in 1:m]

#     start_time = time()
#     last_report = start_time

#     iter = 0
#     while (time() - start_time) < duration
#         iter += 1

#         # ==== Phase GRASP pour chaque alpha ====
#         for (j, alpha) in enumerate(alphas)
#             z = graspSPP(C, A, alpha)
#             push!(the_zs["$j"],  z)
#             if z > Memory[j]
#                 Memory[j] =  z
#             end
#         end

#         # ==== Rapport toutes les 10 secondes ====
#         elapsed = time() - last_report
#         if elapsed >= 10.0
#             last_report = time()

#             # -- Calcul des bornes Zbest / Zworst --
#             z_best = maximum(vcat(values(the_zs)...))
#             z_worst = minimum(vcat(values(the_zs)...))

#             # -- Calcul des Qk --
#             q = [(mean(the_zs["$i"]) - z_worst) / (z_best - z_worst + 1e-9) for i in 1:m]

#             # -- Calcul des Pk --
#             q_sum = sum(q)
#             p = [qi / (q_sum + 1e-9) for qi in q]

#             # -- Sélection du meilleur alpha --
#             k = argmax(p)
#             alpha = alphas[k]
#             qk = q[k]
#             pk = p[k]
#             zk_best = Memory[k]

#             println("Temps écoulé : ", round(time() - start_time, digits=1), " s")
#             println("Sélection de α = ", round(alpha, digits=2),
#                     " | Pk = ", round(pk, digits=3),
#                     " | Qk = ", round(qk, digits=3),
#                     " | Z_best = ", zk_best)
#             println("------------------------------------------------------")

#             # Réinitialisation partielle pour la phase suivante
#             the_zs = Dict("$i" => [] for i in 1:m)
#         end
#     end

#     println("Fin de l’exécution après ", round(time() - start_time, digits=1), " secondes.")
#     println("Meilleures valeurs mémorisées : ", Memory)
#     return Memory
# end


function rgrasp_timed(C, A, m=6; duration=60.0)
    # --- Initialisation ---
    the_zs = Dict("$i" => [] for i in 1:m)
    alphas = range(start=0, stop=1, length=m)
    Memory = [0.0 for _ in 1:m]

    # Dictionnaire pour stocker les mesures temporelles
    metrics = Dict("t" => Float64[],
                   "zmin" => Float64[],
                   "zmax" => Float64[],
                   "zmoy" => Float64[])

    start_time = time()
    last_report = start_time

    iter = 0
    while (time() - start_time) < duration
        iter += 1

        # ==== Phase GRASP pour chaque alpha ====
        for (j, alpha) in enumerate(alphas)
            z = graspSPP(C, A, alpha)
            push!(the_zs["$j"], z)
            if z > Memory[j]
                Memory[j] = z
            end
        end

        # ==== Rapport toutes les 10 secondes ====
        elapsed = time() - last_report
        if elapsed >= 10.0
            last_report = time()

            # -- Calcul des bornes Zbest / Zworst --
            z_best = maximum(vcat(values(the_zs)...))
            z_worst = minimum(vcat(values(the_zs)...))
            z_mean = mean(vcat(values(the_zs)...))

            # -- Sauvegarde dans metrics --
            push!(metrics["t"], round(time() - start_time, digits=1))
            push!(metrics["zmin"], z_worst)
            push!(metrics["zmax"], z_best)
            push!(metrics["zmoy"], round(z_mean, digits=2))

            # -- Calcul des Qk --
            q = [(mean(the_zs["$i"]) - z_worst) / (z_best - z_worst + 1e-9) for i in 1:m]

            # -- Calcul des Pk --
            q_sum = sum(q)
            p = [qi / (q_sum + 1e-9) for qi in q]

            # -- Sélection du meilleur alpha --
            k = argmax(p)
            alpha = alphas[k]
            qk = q[k]
            pk = p[k]
            zk_best = Memory[k]

            println("Temps écoulé : ", round(time() - start_time, digits=1), " s")
            println("α = ", round(alpha, digits=2),
                    " | Pk = ", round(pk, digits=3),
                    " | Qk = ", round(qk, digits=3),
                    " | Z_best = ", zk_best)
            println("Zmin = ", round(z_worst, digits=2),
                    " | Zmax = ", round(z_best, digits=2),
                    " | Zmoy = ", round(z_mean, digits=2))
            println("------------------------------------------------------")

            # Réinitialisation partielle
            the_zs = Dict("$i" => [] for i in 1:m)
        end
    end

    println("Fin de l’exécution après ", round(time() - start_time, digits=1), " secondes.")
    println("Meilleures valeurs mémorisées : ", Memory)
    return metrics
end
