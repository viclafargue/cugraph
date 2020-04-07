/*
 * Copyright (c) 2020, NVIDIA CORPORATION.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "force_atlas2.h"

namespace cugraph {

template <typename VT, typename ET, typename WT>
void force_atlas2(experimental::GraphCOO<VT, ET, WT> const &graph,
                  float *x_pos, float *y_pos, const int max_iter,
                  float *x_start,
                  float *y_start, bool outbound_attraction_distribution,
                  bool lin_log_mode, bool prevent_overlapping,
                  const float edge_weight_influence,
                  const float jitter_tolerance, bool barnes_hut_optimize,
                  const float barnes_hut_theta, const float scaling_ratio,
                  bool strong_gravity_mode, const float gravity) {

    CUGRAPH_EXPECTS( x_pos != nullptr,
            "Invid API parameter: X_pos array should be of size V" );
    CUGRAPH_EXPECTS( y_pos != nullptr ,
            "Invid API parameter: Y_pos array should be of size V" );

    const VT *row = graph.src_indices;
    const VT *col = graph.dst_indices;
    const WT *v = graph.edge_data;
    const ET e = graph.number_of_edges * 2;
    const VT n = graph.number_of_vertices;

    if (v && !barnes_hut_optimize) {
        cugraph::detail::exact_fa2<true, VT, ET, WT>(row, col, v, e, n,
                x_pos, y_pos, max_iter, x_start,
                y_start, outbound_attraction_distribution,
                lin_log_mode, prevent_overlapping, edge_weight_influence,
                jitter_tolerance,
                scaling_ratio, strong_gravity_mode, gravity);
    } else if(!v && !barnes_hut_optimize) {
        cugraph::detail::exact_fa2<false, VT, ET, WT>(row, col, v, e, n,
                x_pos, y_pos, max_iter, x_start,
                y_start, outbound_attraction_distribution,
                lin_log_mode, prevent_overlapping, edge_weight_influence,
                jitter_tolerance,
                scaling_ratio, strong_gravity_mode, gravity);
    } else if(v && barnes_hut_optimize) {
        cugraph::detail::barnes_hut<true, VT, ET, WT>(row, col, v, e, n,
                x_pos, y_pos, max_iter, x_start,
                y_start, outbound_attraction_distribution,
                lin_log_mode, prevent_overlapping, edge_weight_influence,
                jitter_tolerance, barnes_hut_theta,
                scaling_ratio, strong_gravity_mode, gravity);
    } else {
        cugraph::detail::barnes_hut<false, VT, ET, WT>(row, col, v, e, n,
                x_pos, y_pos, max_iter, x_start,
                y_start, outbound_attraction_distribution,
                lin_log_mode, prevent_overlapping, edge_weight_influence,
                jitter_tolerance, barnes_hut_theta,
                scaling_ratio, strong_gravity_mode, gravity);
    }
}

template void force_atlas2<int, int, float>(
        experimental::GraphCOO<int, int, float> const &graph,
        float *x_pos, float *y_pos, const int max_iter,
        float *x_start, float *y_start,
        bool outbound_attraction_distribution,
        bool lin_log_mode, bool prevent_overlapping,
        const float edge_weight_influence, const float jitter_tolerance,
        bool barnes_hut_optimize, const float barnes_hut_theta,
        const float scaling_ratio, bool strong_gravity_mode,
        const float gravity);

} // namespace cugraph
