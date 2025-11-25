include("graspGraphics.jl")
include("graspSPP.jl")
using Statistics, Dates

function rgrasp_timed(C, A, m=6, duration=60.0)
    the_zs = Dict("$i" => [] for i in 1:m)
    alphas = range(start=0, stop=1, length=m)
    Memory = [0.0 for _ in 1:m]

    start_time = time()
    last_report = start_time

    iter = 0
    while (time() - start_time) < duration
        iter += 1

        # ==== Phase GRASP pour chaque alpha ====
        for (j, alpha) in enumerate(alphas)
            z = graspSPP(C, A, alpha)
            push!(the_zs["$j"],  z)
            if z > Memory[j]
                Memory[j] =  z
            end
        end

        # ==== Rapport toutes les 10 secondes ====
        elapsed = time() - last_report
        if elapsed >= 10.0
            last_report = time()

            # -- Calcul des bornes Zbest / Zworst --
            z_best = maximum(vcat(values(the_zs)...))
            z_worst = minimum(vcat(values(the_zs)...))

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

            println("⏱ Temps écoulé : ", round(time() - start_time, digits=1), " s")
            println("  → Sélection de α = ", round(alpha, digits=2),
                    " | Pk = ", round(pk, digits=3),
                    " | Qk = ", round(qk, digits=3),
                    " | Z_best = ", zk_best)
            println("------------------------------------------------------")

            # Réinitialisation partielle pour la phase suivante
            the_zs = Dict("$i" => [] for i in 1:m)
        end
    end

    println("\n✅ Fin de l’exécution après ", round(time() - start_time, digits=1), " secondes.")
    println("Meilleures valeurs mémorisées : ", Memory)
    return Memory
end
