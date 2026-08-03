#-------------------------------------------------------------------------
#Aim:
#introduce granular-ball and propose a granular-ball-based DP algorithm, called GB-DP
# -------------------------------------------------------------------------
# Written by Dongdong Cheng, Ya Li
# Chongqing University of Posts and Telecommunications
# 2023

import os
os.environ["OMP_NUM_THREADS"] = "1"

import time
import numpy as np
import matplotlib.pyplot as plt

from scipy.spatial.distance import pdist, squareform
# 璁＄畻涓ょ偣璺濈
from matplotlib.widgets import RectangleSelector
from sklearn.cluster import k_means
import matplotlib
matplotlib.use('TkAgg')  # 浣跨敤鏀寔浜や簰鐨勫悗绔?

def draw_point(data):
    N = data.shape[0]
    plt.figure()
    plt.axis()
    for i in range(N):
        plt.scatter(data[i][0],data[i][1],s=16.,c='k')
        plt.xlabel('x')
        plt.ylabel('y')
        plt.title('origin graph')
    plt.show()

# 鍒ゆ柇绮掔悆鐨勬爣绛惧拰绾害
def get_num(gb):
    # 鐭╅樀鐨勮鏁?
    num = gb.shape[0]
    return num

# 杩斿洖绮掔悆涓績鍜屽崐寰?
def calculate_center_and_radius(gb):
    data_no_label = gb[:,:]#鍙栧潗鏍?
    center = data_no_label.mean(axis=0)#鍘嬬缉琛岋紝瀵瑰垪鍙栧潎鍊? 鍙栧嚭骞冲潎鐨?x,y
    radius = np.max((((data_no_label - center) ** 2).sum(axis=1) ** 0.5))  #锛坸1-x1锛?*2 + (y1-y2)**2   鎵€鏈夌偣鍒颁腑蹇冪殑璺濈骞冲潎
    return center, radius

def gb_plot(gb_list, plt_type=0):
    plt.figure()
    plt.axis()
    for gb in gb_list:
        center, radius = calculate_center_and_radius(gb)  # 杩斿洖涓績鍜屽崐寰?
        if plt_type == 0:  # 缁樺埗鎵€鏈夌偣
            plt.plot(gb[:, 0], gb[:, 1], '.', c='k', markersize=5)
        if plt_type == 0 or plt_type == 1:  # 缁樺埗绮掔悆
            theta = np.arange(0, 2 * np.pi, 0.01)
            x = center[0] + radius * np.cos(theta)
            y = center[1] + radius * np.sin(theta)
            plt.plot(x, y, c='r', linewidth=0.8)
        plt.plot(center[0], center[1], 'x' if plt_type == 0 else '.', color='r')  # 缁樺埗绮掔悆涓績
    plt.show()


def splits(gb_list, num, splitting_method):
    gb_list_new = []
    for gb in gb_list:
        p = get_num(gb)
        if p < num:
            gb_list_new.append(gb)#璇ョ矑鐞冨寘鍚殑鐐规暟灏忎簬绛変簬num锛岄偅
        else:
            gb_list_new.extend(splits_ball(gb, splitting_method))#鍙嶄箣锛岃繘琛屽垝鍒嗭紝鏈潵鏄痆[1],[2],[3]]  鍙樻垚[...,[1],[2],[3]]
    return gb_list_new

def splits_ball(gb, splitting_method):
    splits_k = 2
    ball_list = []

    # 鏁扮粍鍘婚噸
    len_no_label = np.unique(gb, axis=0)
    if splitting_method == '2-means':
        if len_no_label.shape[0] < splits_k:
            splits_k = len_no_label.shape[0]
        # n_init:鐢ㄤ笉鍚岃仛绫讳腑蹇冨垵濮嬪寲杩愯绠楁硶鐨勬鏁?
        #random_state锛岄€氳繃鍥哄畾瀹冪殑鍊硷紝姣忔鍙互鍒嗗壊寰楀埌鍚屾牱鐨勮缁冮泦鍜屾祴璇曢泦
        label = k_means(X=gb, n_clusters=splits_k, n_init=1, random_state=8)[1]  # 杩斿洖鏍囩
    elif splitting_method == 'center_split':
        # 閲囩敤姝ｃ€佽礋绫讳腑蹇冪洿鎺ュ垝鍒?
        p_left = gb[gb[:, 0] == 1, 1:].mean(0)#姹傚潗鏍囧钩鍧囧€?
        p_right = gb[gb[:, 0] == 0, 1:].mean(0)
        distances_to_p_left = distances(gb, p_left)#姹傚嚭鍚勭偣鍒板钩鍧囩偣鐨勮窛绂?
        distances_to_p_right = distances(gb, p_right)

        relative_distances = distances_to_p_left - distances_to_p_right
        label = np.array(list(map(lambda x: 0 if x <= 0 else 1, relative_distances)))

    elif splitting_method == 'center_means':
        # 閲囩敤姝ｈ礋绫讳腑蹇冧綔涓?2-means 鐨勫垵濮嬩腑蹇冪偣
        p_left = gb[gb[:, 0] == 1, 1:].mean(0)
        p_right = gb[gb[:, 0] == 0, 1:].mean(0)
        centers = np.vstack([p_left, p_right])#[[],[]]
        label = k_means(X=gb, n_clusters=2, init=centers, n_init=10)[1]#浠enters涓轰腑蹇冭繘琛岃仛绫?
    else:
        return gb
    for single_label in range(0, splits_k):
        ball_list.append(gb[label == single_label, :])#鎸夌収鏂版墦鐨勬爣绛惧垎绫?

    return ball_list


# 璺濈
def distances(data, p):
    return ((data - p) ** 2).sum(axis=1) ** 0.5


#璁＄畻鎵€鏈夌偣鍒扮矑鐞冧腑蹇冪殑骞冲潎璺濈锛?
def get_ball_quality(gb, center):
    N = gb.shape[0]
    ball_quality =  N
    mean_r = np.mean(((gb - center) **2)**0.5)
    return ball_quality, mean_r


#璁＄畻绮掔悆鐨勫瘑搴?--璁＄畻瀵嗗害鐨勬柟娉曚簩锛氱矑鐞冪殑瀵嗗害=绮掔悆鐨勮川閲?绮掔悆鐨勪綋绉?
#绮掔悆鐨勮川閲?鎵€鏈夌偣鍒颁腑蹇冪偣鐨勫钩鍧囪窛绂? 浣撶Н=绮掔悆鍗婂緞鐨勭淮鏁版鏂箁adiusA, dimen, ball_qualitysA
def ball_density2(radiusAD, ball_qualitysA, mean_rs):
    N = radiusAD.shape[0]
    ball_dens2 = np.zeros(shape=N)
    for i in range(N):
        if radiusAD[i] == 0:
            ball_dens2[i] = 0
        else:
            ball_dens2[i] = ball_qualitysA[i] / (radiusAD[i] * radiusAD[i] * mean_rs[i])
    return ball_dens2


#璁＄畻绮掔悆鐨勭浉瀵硅窛绂?
def ball_distance(centersAD):
    Y1 = pdist(centersAD)
    ball_distAD = squareform(Y1)
    return ball_distAD

#璁＄畻鏈€灏忓瘑搴﹀嘲璺濈浠ュ強璇ョ偣ball_min_dist3
def ball_min_dist(ball_distS, ball_densS):
    N3 = ball_distS.shape[0]
    ball_min_distAD = np.zeros(shape=N3)
    ball_nearestAD = np.zeros(shape=N3)
    #鎸夊瘑搴︿粠澶у埌灏忔帓鍙?
    index_ball_dens = np.argsort(-ball_densS)
    for i3, index in enumerate(index_ball_dens):
        if i3 == 0:
            continue
        index_ball_higher_dens = index_ball_dens[:i3]
        ball_min_distAD[index] = np.min([ball_distS[index, j]for j in index_ball_higher_dens])
        ball_index_near = np.argmin([ball_distS[index, j]for j in index_ball_higher_dens])
        ball_nearestAD[index] = int(index_ball_higher_dens[ball_index_near])
    ball_min_distAD[index_ball_dens[0]] = np.max(ball_min_distAD)
    if np.max(ball_min_distAD) < 1:
        ball_min_distAD = ball_min_distAD * 10
    return ball_min_distAD, ball_nearestAD

#鐢诲浘
def ball_draw_decision(ball_densS, ball_min_distS):
    Bval1_start = time.time()
    fig, ax = plt.subplots()
    N = ball_densS.shape[0]
    lst = []
    for i4 in range(N):
        ax.plot(ball_densS[i4], ball_min_distS[i4], marker='o', markersize=4.0, c='k')
        plt.xlabel('density')
        plt.ylabel('min_dist')
        ax.set_title('decision graph')
        # 鐭╁舰閫夊尯閫夋嫨鏃剁殑鍥炶皟鍑芥暟
    def select_callback(eclick, erelease):
        x1, y1 = eclick.xdata, eclick.ydata
        x2, y2 = erelease.xdata, erelease.ydata
        lst.append([x1, y1, x2, y2])  # 鎴栨牴鎹渶瑕佽皟鏁磋繖閲岀殑浠ｇ爜

    RS = RectangleSelector(ax, select_callback,
                           useblit=True,
                           button=[1, 3],  # 鍚敤宸﹂敭鍜屽彸閿?
                           minspanx=5, minspany=5,
                           spancoords='pixels',
                           interactive=True)
    # a = Annotate()
    plt.show()
    Bval1_end = time.time()
    Bval1 = Bval1_end - Bval1_start
    return lst, Bval1



#鎵剧矑鐞冧腑蹇冪偣
def ball_find_centers(ball_densS, ball_min_distS, lst):
    ball_density_threshold = lst[0][0]
    ball_min_dist_threshold = lst[0][1]
    centers = []
    N4 = ball_densS.shape[0]
    for i4 in range(N4):
        if ball_densS[i4] >= ball_density_threshold and ball_min_distS[i4] >= ball_min_dist_threshold:
            centers.append(i4)
    return np.array(centers)

# def ball_find_centers(ball_densS, ball_min_distS, cl=5):
#     # 璁＄畻ball_densS鍜宐all_min_distS鐨勯€愬厓绱犱箻绉?
#     product = ball_densS * ball_min_distS
#
#     # 鎵惧埌涔樼Н涓渶澶х殑cl涓€肩殑绱㈠紩
#     top_cl_indices = np.argsort(-product)[:cl]
#
#     # 閫夋嫨杩欎簺绱㈠紩瀵瑰簲鐨勪腑蹇冪偣
#     centers = []
#     for index in top_cl_indices:
#         centers.append(index)
#
#     return np.array(centers)


def ball_cluster(ball_densS, ball_centers, ball_nearest, ball_min_distS):
    K1 = len(ball_centers)
    if K1 == 0:
        print('no centers')
        return
    N5 = ball_densS.shape[0]
    ball_labs = -1 * np.ones(N5).astype(int)
    for i5, cen1 in enumerate(ball_centers):
        ball_labs[cen1] = int(i5+1)
    ball_index_density = np.argsort(-ball_densS)
    for i5, index2 in enumerate(ball_index_density):
        if ball_labs[index2] == -1:
            ball_labs[index2] = ball_labs[int(ball_nearest[index2])]
    return ball_labs

# def  ball_draw_cluster(centersA, radiusA, ball_labs, dic_colors, gb_list, ball_centers):
#  #   plt.figure()
#     N6 = centersA.shape[0]
#     with open('point_labels.txt', 'w') as file:
#         for i6 in range(N6):
#             for j6, point in enumerate(gb_list[i6]):
#              #    plt.plot(point[0], point[1], marker='o', markersize=4.0, color=dic_colors[ball_labs[i6]])
#                  file.write(str(ball_labs[i6]) + '\n')
#               #   file.write(f"{point[0]} {point[1]} {ball_labs[i6]}\n")
#   #  plt.show()

def ball_draw_cluster(centersA, radiusA, ball_labs, dic_colors, gb_list, ball_centers):
    with open('point_labels.txt', 'w') as file:
        for gb, cluster_label in zip(gb_list, ball_labs):
            for point in gb:
                # 灏嗙偣鐨勬墍鏈夊潗鏍囪浆鎹负鐢辩┖鏍煎垎闅旂殑瀛楃涓?
             #   point_str = ' '.join(map(str, point))
             #   point_str = ' '.join(map(lambda x: str(int(x)), point)) # 灏嗙偣鐨勬墍鏈夊潗鏍囪浆鎹负鏁存暟锛岀劧鍚庤浆鎹负鐢辩┖鏍煎垎闅旂殑瀛楃涓?
                # 浣跨敤 repr() 鐢熸垚娴偣鏁扮殑瀛楃涓茶〃绀猴紝淇濈暀鍘熷绮惧害
                point_str = ' '.join(map(repr, point))
                # 灏嗙偣鐨勬墍鏈夊潗鏍囪浆鎹负灏忔暟鏍煎紡鐨勫瓧绗︿覆锛屼繚鐣?5浣嶅皬鏁?
            #    point_str = ' '.join(f"{float(coord):.15f}" for coord in point)
            #    file.write(f"{point_str} {cluster_label}\n")
                file.write(f"{cluster_label}\n")



if __name__ == "__main__":
    from pathlib import Path

    repo_root = Path(__file__).resolve().parents[2]
dic_colors = {0: (.8, 0, 0), 1: (0, .8, 0),
                  2: (0, 0, .8), 3: (.8, .8, 0),
                  4: (.8, 0, .8), 5: (0, .8, .8),
                  6: (0, 0, 0), 7: (0.8, 0.8, 0.8),
                  8: (0.6, 0, 0), 9: (0, 0.6, 0),
                  10: (1, 0, .8), 11: (0, 1, .8),
                  12: (1, 1, .8), 13: (0.4, 0, .8),
                  14: (0, 0.4, .8), 15: (0.4, 0.4, .8),
                  16: (1, 0.4, .8), 17: (1, 0, 1),
                  18: (1, 0, .8), 19: (.8, 0.2, 0), 20: (0, 0.7, 0),
                  21: (0.9, 0, .8), 22: (.8, .8, 0.1),
                  23: (.8, 0.5, .8), 24: (0, .1, .8),
                  25: (0.9, 0, .8), 26: (.8, .8, 0.1),
                  27: (.8, 0.5, .8), 28: (0, .1, .8),
                  29: (0, .1, .8)
                  }


    np.set_printoptions(threshold=1e16)

    #data_mat = np.loadtxt('data/Skin.txt')
    # data = np.loadtxt(repo_root / 'datasets' / '3M2D5' / 'data.txt')
    # data_mat = np.loadtxt(repo_root / 'datasets' / 'Flower' / 'data.txt')
    data = np.loadtxt(repo_root / 'datasets' / 'N-BaIoT' / 'whole_data.txt')

    #寮€濮嬫椂闂?
    start = time.time()
    # data = data_mat
    num = np.ceil(np.sqrt(data.shape[0]))
    # print(max_radius)
    gb_list = [data]
    #鍏ㄩ儴绮掔悆鐨勫睍绀猴紝涓嶅寘鎷湪鏃堕棿鐨勮绠椾腑
    # draw_point(data)
    #缁樺埗鍒濆绮掔悆
    # gb_plot(gb_list)
    while True:
        ball_number_1 = len(gb_list)  # 鐐规暟
        gb_list = splits(gb_list, num=num, splitting_method='2-means')
        ball_number_2 = len(gb_list)  # 琚垝鍒嗘垚浜嗗嚑涓?
        # gb_plot(gb_list)
        if ball_number_1 == ball_number_2:  # 娌℃湁鍒掑垎鍑烘柊鐨勭矑鐞?
            break


    centers = []
    radiuss = []
    ball_num = []#绮掔悆閲岄潰鐨勫厓绱犱釜鏁?
    ball_qualitys = []#姣忎釜绮掔悆鐨勮川閲?
    mean_rs = []
    i = 0
    for gb in gb_list:
        center, radius = calculate_center_and_radius(gb)
        ball_quality, mean_r = get_ball_quality(gb, center)
        ball_qualitys.append(ball_quality)
        mean_rs.append(mean_r)
        centers.append(center)
        radiuss.append(radius)
        ball_num.append(gb.shape[0])
    centersA = np.array(centers)
    radiusA = np.array(radiuss)
    ball_numA = np.array(ball_num)
    ball_qualitysA = np.array(ball_qualitys)#姣忎竴涓矑鐞冪殑鍗婂緞鍜屼腑蹇?
    print('radiusA:',radiusA)
    print('ball_qualitysA:', ball_qualitysA)
    print('mean_rs:', mean_rs)
    ball_densS = ball_density2(radiusA, ball_qualitysA, mean_rs)

    #璁＄畻姣忎釜绮掔悆鐨勭浉瀵硅窛绂?
    ball_distS = ball_distance(centersA)
    #璁＄畻鏈€灏忓瘑搴﹀嘲璺濈浠ュ強璇ョ偣ball_min_dist  ball_min_distAD, ball_nearestAD
    ball_min_distS, ball_nearest = ball_min_dist(ball_distS, ball_densS)
    # Bval1閫変腑涓績鎵€鑺辩殑鏃堕棿
    start1 = time.time()
    lst, Bval1 = ball_draw_decision(ball_densS, ball_min_distS)
    end1 = time.time()
    ball_centers = ball_find_centers(ball_densS, ball_min_distS, lst)
    print(ball_centers)
    ball_labs = ball_cluster(ball_densS, ball_centers, ball_nearest, ball_min_distS)
    end = time.time()
 #   times = (end - start) - (end1 - start1)
 #   print('The running time is锛?s s ' % (times))       鍘熸湰鎶婃椂闂存斁杩?
    print('Please wait for drawing clustering results......')
    # 鏈€鍚庣殑鑱氱被缁撴灉
    ball_draw_cluster(centersA, radiusA, ball_labs, dic_colors, gb_list, ball_centers)
    times = (end - start) - (end1 - start1)         #  鎴戣寰楀簲璇ユ斁鐫€
    print('The running time is锛?s s ' % (times))
    print('Complete!')












