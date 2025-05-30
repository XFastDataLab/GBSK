#include "cover_tree.h"
#include <limits.h>
#include <values.h>
#include <stdint.h>
#include <iostream>
using namespace std;
#define MAXFLOAT 0x1.fffffeP127f
struct ds_node {
  v_array<float> dist;
  point p;
};

float base = 1.3;

float il2 = 1. / log(base);
inline float dist_of_scale (int s)
{
  return pow(base, s);
}

inline int get_scale(float d)
{
  return (int) ceilf(il2 * log(d));
}
#include<numeric>

int min(int f1, int f2)
{
  if ( f1 <= f2 )
    return f1;
  else
    return f2;
}

float max(float f1, float f2)
{
  if ( f1 <= f2 )
    return f2;
  else
    return f1;
}

node new_node(const point &p)
{
  node new_node;
  new_node.p = p;
  return new_node;
}

node new_leaf(const point &p)
{
  node new_leaf = {p,0.,0.,NULL,0,100};
  return new_leaf;
}

float max_set(v_array<ds_node> &v)
{
  float max = 0.;
  for (int i = 0; i < v.index; i++)
    if ( max < v[i].dist.last())
      max = v[i].dist.last();
  return max;
}

void print_space(int s)
{
  for (int i = 0; i < s; i++)
    printf(" ");
}

void print(int depth, node &top_node)
{
  print_space(depth);
  print(top_node.p);
  if ( top_node.num_children > 0 ) {
    print_space(depth); printf("scale = %i\n",top_node.scale);
    print_space(depth); printf("max_dist = %f\n",top_node.max_dist);
    print_space(depth); printf("num children = %i\n",top_node.num_children);
    for (int i = 0; i < top_node.num_children;i++)
      print(depth+1, top_node.children[i]);
  }
}

void split(v_array<ds_node>& point_set, v_array<ds_node>& far_set, int max_scale)
{
  unsigned int new_index = 0;
  float fmax = dist_of_scale(max_scale);
  for (int i = 0; i < point_set.index; i++){
    if (point_set[i].dist.last() <= fmax) {
      point_set[new_index++] = point_set[i];
    }
    else
      push(far_set,point_set[i]);
  }
  point_set.index=new_index;
}

void dist_split(v_array<ds_node>& point_set,
		v_array<ds_node>& new_point_set,
		point new_point,
		int max_scale)
{
  unsigned int new_index = 0;
  float fmax = dist_of_scale(max_scale);
  for(int i = 0; i < point_set.index; i++)
    {
      float new_d;
      new_d = distance(new_point, point_set[i].p, fmax);
      if (new_d <= fmax ) {
	push(point_set[i].dist, new_d);
	push(new_point_set,point_set[i]);
      }
      else
	point_set[new_index++] = point_set[i];
    }
  point_set.index = new_index;
}

/*
   max_scale is the maximum scale of the node we might create here.
   point_set contains points which are 2*max_scale or less away.
*/

node batch_insert(const point& p,
		  int max_scale,
		  int top_scale,
		  v_array<ds_node>& point_set,
		  v_array<ds_node>& consumed_set,
		  v_array<v_array<ds_node> >& stack)
{
  if (point_set.index == 0)
    return new_leaf(p);
  else {
    float max_dist = max_set(point_set); //O(|point_set|)
    int next_scale = min (max_scale - 1, get_scale(max_dist));
    if (next_scale < -100) // We have points with distance 0.
      {
	v_array<node> children;
	push(children,new_leaf(p));
	while (point_set.index > 0)
	  {
	    push(children,new_leaf(point_set.last().p));
	    push(consumed_set,point_set.last());
	    point_set.decr();
	  }
	node n = new_node(p);
	n.scale = 100; // A magic number meant to be larger than all scales.
	n.max_dist = 0;
	alloc(children,children.index);
	n.num_children = children.index;
	n.children = children.elements;
	return n;
      }
    else
      {
	v_array<ds_node> far = pop(stack);
	split(point_set,far,max_scale); //O(|point_set|)

	node child = batch_insert(p, next_scale, top_scale, point_set, consumed_set, stack);

	if (point_set.index == 0)
	  {
	    push(stack,point_set);
	    point_set=far;
	    return child;
	  }
	else {
	  node n = new_node(p);
	  v_array<node> children;
	  push(children, child);
	  v_array<ds_node > new_point_set = pop(stack);
	  v_array<ds_node > new_consumed_set = pop(stack);
	  while (point_set.index != 0) { //O(|point_set| * num_children)
	    point new_point = point_set.last().p;
	    float new_dist = point_set.last().dist.last();
	    push(consumed_set, point_set.last());
	    point_set.decr();

	    dist_split(point_set, new_point_set, new_point, max_scale); //O(|point_saet|)
	    dist_split(far,new_point_set,new_point,max_scale); //O(|far|)

	    node new_child =
	      batch_insert(new_point, next_scale, top_scale, new_point_set, new_consumed_set, stack);
	    new_child.parent_dist = new_dist;

	    push(children, new_child);

	    float fmax = dist_of_scale(max_scale);
	    for(int i = 0; i< new_point_set.index; i++) //O(|new_point_set|)
	      {
		new_point_set[i].dist.decr();
		if (new_point_set[i].dist.last() <= fmax)
		  push(point_set, new_point_set[i]);
		else
		  push(far, new_point_set[i]);
	      }
	    for(int i = 0; i< new_consumed_set.index; i++) //O(|new_point_set|)
	      {
		new_consumed_set[i].dist.decr();
		push(consumed_set, new_consumed_set[i]);
	      }
	    new_point_set.index = 0;
	    new_consumed_set.index = 0;
	  }
	  push(stack,new_point_set);
	  push(stack,new_consumed_set);
	  push(stack,point_set);
	  point_set=far;
	  n.scale = top_scale - max_scale;
	  n.max_dist = max_set(consumed_set);
	  alloc(children,children.index);
	  n.num_children = children.index;
	  n.children = children.elements;
	  return n;
	}
      }
  }
}

node batch_create(v_array<point> points)
{
  assert(points.index > 0);
  v_array<ds_node > point_set;
  v_array<v_array<ds_node > > stack;

  for (int i = 1; i < points.index; i++) {
    ds_node temp;
    push(temp.dist, distance(points[0], points[i], MAXFLOAT));
    temp.p = points[i];
    push(point_set,temp);
  }
  v_array<ds_node> consumed_set;

  float max_dist = max_set(point_set);

  node top = batch_insert (points[0],
			   get_scale(max_dist),
			   get_scale(max_dist),
			    point_set,
			    consumed_set,
			    stack);
  for (int i = 0; i<consumed_set.index;i++)
    free(consumed_set[i].dist.elements);
  free(consumed_set.elements);
  for (int i = 0; i<stack.index;i++)
    free(stack[i].elements);
  free(stack.elements);
  free(point_set.elements);
  return top;
}

void add_height(int d, v_array<int> &heights)
{
  if (heights.index <= d)
    for(;heights.index <= d;)
      push(heights,0);
  heights[d] = heights[d] + 1;
}

int height_dist(const node top_node,v_array<int> &heights)
{
  if (top_node.num_children == 0)
    {
      add_height(0,heights);
      return 0;
    }
  else
    {
      int max_v=0;
      for (int i = 0; i<top_node.num_children ;i++)
	{
	  int d = height_dist(top_node.children[i], heights);
	  if (d > max_v)
	    max_v = d;
	}
      add_height(1 + max_v, heights);
      return (1 + max_v);
    }
}

void depth_dist(int top_scale, const node top_node,v_array<int> &depths)
{
  if (top_node.num_children > 0)
      for (int i = 0; i<top_node.num_children ;i++)
	{
	  add_height(top_node.scale, depths);
	  depth_dist(top_scale, top_node.children[i], depths);
	}
}

void breadth_dist(const node top_node,v_array<int> &breadths)
{
  if (top_node.num_children == 0)
    add_height(0,breadths);
  else
    {
      for (int i = 0; i<top_node.num_children ;i++)
	breadth_dist(top_node.children[i], breadths);
      add_height(top_node.num_children, breadths);
    }
}

struct d_node {
  float dist;
  const node *n;
};

inline float compare(const d_node *p1, const d_node* p2)
{
  return p1 -> dist - p2 -> dist;
}

#define SWAP(a, b)				\
  do						\
    {						\
      d_node tmp = * a;				\
      * a = * b;				\
      * b = tmp;				\
    } while (0)

void halfsort (v_array<d_node > cover_set)
{
  if (cover_set.index <= 1)
    return;
  register d_node *base_ptr =  cover_set.elements;

  d_node *hi = &base_ptr[cover_set.index - 1];
  d_node *right_ptr = hi;
  d_node *left_ptr;

  while (right_ptr > base_ptr)
    {
      d_node *mid = base_ptr + ((hi - base_ptr) >> 1);

      if (compare ( mid,  base_ptr) < 0.)
	SWAP (mid, base_ptr);
      if (compare ( hi,  mid) < 0.)
	SWAP (mid, hi);
      else
	goto jump_over;
      if (compare ( mid,  base_ptr) < 0.)
	SWAP (mid, base_ptr);
    jump_over:;

      left_ptr  = base_ptr + 1;
      right_ptr = hi - 1;

      do
	{
	  while (compare (left_ptr, mid) < 0.)
	    left_ptr ++;

	  while (compare (mid, right_ptr) < 0.)
	    right_ptr --;

	  if (left_ptr < right_ptr)
	    {
	      SWAP (left_ptr, right_ptr);
	      if (mid == left_ptr)
		mid = right_ptr;
	      else if (mid == right_ptr)
		mid = left_ptr;
	      left_ptr ++;
	      right_ptr --;
	    }
	  else if (left_ptr == right_ptr)
	    {
	      left_ptr ++;
	      right_ptr --;
	      break;
	    }
	}
      while (left_ptr <= right_ptr);

      hi = right_ptr;
    }
}

v_array<v_array<d_node> > get_cover_sets(v_array<v_array<v_array<d_node> > > &spare_cover_sets)
{
  v_array<v_array<d_node> > ret = pop(spare_cover_sets);
  while (ret.index < 101)
    {
      v_array<d_node> temp;
      push(ret, temp);
    }
  return ret;
}

inline bool shell(float parent_query_dist, float child_parent_dist, float upper_bound)
{
  return parent_query_dist - child_parent_dist <= upper_bound;
  //    && child_parent_dist - parent_query_dist <= upper_bound;
}

int internal_k =1;
void update_k(float *k_upper_bound, float upper_bound)
{
    float *end = k_upper_bound + internal_k-1;
    float *begin = k_upper_bound;
    for( ;end != begin; begin++)
    {
        if(upper_bound < *(begin+1))
            *begin = *(begin+1);
        else{
            *begin = upper_bound;
            break;
        }
    }
    if(end == begin)
        *begin = upper_bound;
}

float *alloc_k()
{
  return (float *)malloc(sizeof(float) * internal_k);
}

void set_k(float* begin, float max)
{
  for(float *end = begin+internal_k;end != begin; begin++)
    *begin = max;
}

float internal_epsilon =0.;
void update_epsilon(float *upper_bound, float new_dist) {}

float *alloc_epsilon()
{
  return (float *)malloc(sizeof(float));
}

void set_epsilon(float* begin, float max)
{
  *begin = internal_epsilon;
}

void update_unequal(float *upper_bound, float new_dist)
{
  if (new_dist != 0.)
    *upper_bound = new_dist;
}
float* (*alloc_unequal)() = alloc_epsilon;
void set_unequal(float* begin, float max)
{
  *begin = max;
}

void (*update)(float *foo, float bar) = update_k;
void (*setter)(float *foo, float bar) = set_k;
float* (*alloc_upper)() = alloc_k;

inline void copy_zero_set(node* query_chi, float* new_upper_bound,
			    v_array<d_node> &zero_set, v_array<d_node> &new_zero_set)
{
  new_zero_set.index = 0;
  d_node *end = zero_set.elements + zero_set.index;
  for (d_node *ele = zero_set.elements; ele != end ; ele++)
    {
      float upper_dist = *new_upper_bound + 2. * query_chi->max_dist;
      if (shell(ele->dist, query_chi->parent_dist, upper_dist))
	{
	  float d = distance(query_chi->p, ele->n->p, upper_dist);

	  if (d <= upper_dist)
	    {
	      if (d < *new_upper_bound)
		update(new_upper_bound, d);
	      d_node temp = {d, ele->n};
	      push(new_zero_set,temp);
	    }
	}
    }
}

inline void copy_cover_sets(node* query_chi, float* new_upper_bound,
			      v_array<v_array<d_node> > &cover_sets,
			      v_array<v_array<d_node> > &new_cover_sets,
			      int current_scale, int max_scale)
{
  for (; current_scale <= max_scale; current_scale++)
    {
      d_node* ele = cover_sets[current_scale].elements;
      d_node* end = cover_sets[current_scale].elements + cover_sets[current_scale].index;
      for (; ele != end; ele++)
	{
	  float upper_dist = *new_upper_bound + 2. *query_chi->max_dist + ele->n->max_dist;
	  if (shell(ele->dist, query_chi->parent_dist, upper_dist))
	    {
	      float d = distance(query_chi->p, ele->n->p, upper_dist);

	      if (d <= upper_dist)
		{
		  if (d < *new_upper_bound)
		    update(new_upper_bound,d);
		  d_node temp = {d, ele->n};
		  push(new_cover_sets[current_scale],temp);
		}
	    }
	}
    }
}

void print_query(const node *top_node)
{
  printf ("query = \n");
  float *p = (float *)top_node->p;
  print(p);
  if ( top_node->num_children > 0 ) {
    printf("scale = %i\n",top_node->scale);
    printf("max_dist = %f\n",top_node->max_dist);
    printf("num children = %i\n",top_node->num_children);
  }
}

void print_cover_sets(v_array<v_array<d_node> > &cover_sets,
		      v_array<d_node> &zero_set,
		      int current_scale, int max_scale)
{
  printf("cover set = \n");
  for (; current_scale <= max_scale; current_scale++)
    {
      d_node* ele = cover_sets[current_scale].elements;
      d_node* end = cover_sets[current_scale].elements + cover_sets[current_scale].index;
      printf ("%i\n", current_scale);
      for (; ele != end; ele++)
	{
	  node *n = (node *)ele->n;
	  print(n->p);
	}
    }
  d_node *end = zero_set.elements + zero_set.index;
  printf ("infinity\n");
  for (d_node *ele = zero_set.elements; ele != end ; ele++)
    {
      node *n = (node *)ele->n;
      print(n->p);
    }
}


/*
  An optimization to consider:
  Make all distance evaluations occur in descend.

  Instead of passing a cover_set, pass a stack of cover sets.  The
  last element holds d_nodes with your distance.  The next lower
  element holds a d_node with the distance to your query parent,
  next = query grand parent, etc..

  Compute distances in the presence of the tighter upper bound.
 */

inline void descend(const node* query, float* upper_bound,
		      int current_scale,
		      int &max_scale, v_array<v_array<d_node> > &cover_sets,
		      v_array<d_node> &zero_set)
{
  d_node *end = cover_sets[current_scale].elements + cover_sets[current_scale].index;
  for (d_node *parent = cover_sets[current_scale].elements; parent != end; parent++)
    {
      const node *par = parent->n;
      float upper_dist = *upper_bound + query->max_dist + query->max_dist;
      if (parent->dist <= upper_dist + par->max_dist && par->children)
	{
	  node *chi = par->children;
	  if (parent->dist <= upper_dist + chi->max_dist)
	    {
	      if (chi->num_children > 0)
		{
		  if (max_scale < chi->scale)
		    max_scale = chi->scale;
		  d_node temp = {parent->dist, chi};
		  push(cover_sets[chi->scale], temp);
		}
	      else if (parent->dist <= upper_dist)
		{
		  d_node temp = {parent->dist, chi};
		  push(zero_set, temp);
		}
	    }
	  node *child_end = par->children + par->num_children;
	  for (chi++; chi != child_end; chi++)
	    {
	      float upper_chi = *upper_bound + chi->max_dist + query->max_dist + query->max_dist;
	      if (shell(parent->dist, chi->parent_dist, upper_chi))
		{
		  float d = distance(query->p, chi->p, upper_chi);
		  if (d <= upper_chi)
		    {
		      if (d < *upper_bound)
			update(upper_bound, d);
		      if (chi->num_children > 0)
			{
			  if (max_scale < chi->scale)
			    max_scale = chi->scale;
			  d_node temp = {d, chi};
			  push(cover_sets[chi->scale],temp);
			}
		      else
			if (d <= upper_chi - chi->max_dist)
			  {
			    d_node temp = {d, chi};
			    push(zero_set, temp);
			  }
		    }
		}
	    }
	}
    }
}


void brute_nearest(const node* query,v_array<d_node> zero_set,
		   float* upper_bound,
		   v_array<v_array<float> > &results,
		   v_array<v_array<d_node> > &spare_zero_sets,int dim,int K){

    if (query->num_children > 0){
       v_array<d_node> new_zero_set = pop(spare_zero_sets);
       node* query_chi = query->children;
       brute_nearest(query_chi, zero_set, upper_bound, results, spare_zero_sets,dim,K);
       float* new_upper_bound = alloc_upper();

       node *child_end = query->children + query->num_children;
       for (query_chi++;query_chi != child_end; query_chi++){
           setter(new_upper_bound,*upper_bound + query_chi->parent_dist);
	       copy_zero_set(query_chi, new_upper_bound, zero_set, new_zero_set);
	       brute_nearest(query_chi, new_zero_set, new_upper_bound, results, spare_zero_sets,dim,K);
	   }
       free (new_upper_bound);
       new_zero_set.index = 0;
       push(spare_zero_sets, new_zero_set);
    }
    else{
      v_array<float> temp;
      push(temp, query->p[dim-1]);
      d_node *end = zero_set.elements + zero_set.index;
      for(d_node *ele = zero_set.elements; ele != end ; ele++)
         if(ele->dist <= *upper_bound)
            push(temp, ele->n->p[dim-1]);
      push(results,temp);
      /*
      for(d_node *ele = zero_set.elements; ele != end ; ele++)
         if(ele->dist <= *upper_bound){
            if(temp.index < K)
                push(temp,ele->n->p[dim-1]);
            else{
                float tmp_dist = distance(query->p,ele->n->p,dim-1);

            }
         }
       push(results,temp);
       */
    }
}

//the original brute_nearest has a bug on pushing ele to results.
//here, each element in result has a fixed length, without permission to realloc its space.
void brute_nearest_new(const node* query,v_array<d_node> zero_set,
		   float* upper_bound,
		   v_array<v_array<float> > &results,
		   v_array<v_array<d_node> > &spare_zero_sets,int dim,int K){

    if (query->num_children > 0){
       v_array<d_node> new_zero_set = pop(spare_zero_sets);
       node* query_chi = query->children;
       brute_nearest_new(query_chi, zero_set, upper_bound, results, spare_zero_sets,dim,K);
       float* new_upper_bound = alloc_upper();

       node *child_end = query->children + query->num_children;
       for (query_chi++;query_chi != child_end; query_chi++){
           setter(new_upper_bound,*upper_bound + query_chi->parent_dist);
	       copy_zero_set(query_chi, new_upper_bound, zero_set, new_zero_set);
	       brute_nearest_new(query_chi, new_zero_set, new_upper_bound, results, spare_zero_sets,dim,K);
	   }
       free (new_upper_bound);
       new_zero_set.index = 0;
       push(spare_zero_sets, new_zero_set);
    }
    else{
      //v_array<float> temp;
      //push(temp, query->p[dim-1]);
      int id= results.index;
      push(results[id],query->p[dim-1]);
      d_node *end = zero_set.elements + zero_set.index;
      for(d_node *ele = zero_set.elements; ele != end ; ele++)
         //results[id].length is fixed to K, if the zero elements are more than length
         //the results[id] will be realloced, which is unacceptable.
         //if(ele->dist <= *upper_bound && results[id].length> results.index){
         if(ele->dist <= *upper_bound){
            push1(results[id],ele->n->p[dim-1]);
         }
      results.index++;
            //push(temp, ele->n->p[dim-1]);
      //push(results,temp);
    }
}

void internal_batch_nearest_neighbor_new(const node *query,
				     v_array<v_array<d_node> > &cover_sets,
				     v_array<d_node> &zero_set,
				     int current_scale,
				     int max_scale,
				     float* upper_bound,
				     v_array<v_array<float> > &results,
				     v_array<v_array<v_array<d_node> > > &spare_cover_sets,
				     v_array<v_array<d_node> > &spare_zero_sets,int dim,int K)
{
  if (current_scale > max_scale) // All remaining points are in the zero set.
    brute_nearest_new(query, zero_set, upper_bound, results, spare_zero_sets,dim,K);
  else
    if(query->scale <= current_scale && query->scale != 100)
    // Our query has too much scale.  Reduce.
    {
        node *query_chi = query->children;
        v_array<d_node> new_zero_set = pop(spare_zero_sets);
        v_array<v_array<d_node> > new_cover_sets = get_cover_sets(spare_cover_sets);
        float* new_upper_bound = alloc_upper();

        node *child_end = query->children + query->num_children;
        for (query_chi++; query_chi != child_end; query_chi++)
        {
            setter(new_upper_bound,*upper_bound + query_chi->parent_dist);
            copy_zero_set(query_chi, new_upper_bound, zero_set, new_zero_set);
            copy_cover_sets(query_chi, new_upper_bound, cover_sets, new_cover_sets,
                      current_scale, max_scale);
            internal_batch_nearest_neighbor_new(query_chi, new_cover_sets, new_zero_set,
                            current_scale, max_scale, new_upper_bound,
                             results, spare_cover_sets, spare_zero_sets,dim,K);
        }
        free (new_upper_bound);
        new_zero_set.index = 0;
        push(spare_zero_sets, new_zero_set);
        push(spare_cover_sets, new_cover_sets);
        internal_batch_nearest_neighbor_new(query->children, cover_sets, zero_set,
                        current_scale, max_scale, upper_bound, results,
                        spare_cover_sets, spare_zero_sets,dim,K);
    }
    else // reduce cover set scale
    {
        halfsort(cover_sets[current_scale]);
        descend(query, upper_bound, current_scale, max_scale,cover_sets, zero_set);
        cover_sets[current_scale++].index = 0;
        internal_batch_nearest_neighbor_new(query, cover_sets, zero_set,
                        current_scale, max_scale, upper_bound, results,
                        spare_cover_sets, spare_zero_sets,dim,K);
    }
}


void internal_batch_nearest_neighbor(const node *query,
				     v_array<v_array<d_node> > &cover_sets,
				     v_array<d_node> &zero_set,
				     int current_scale,
				     int max_scale,
				     float* upper_bound,
				     v_array<v_array<float> > &results,
				     v_array<v_array<v_array<d_node> > > &spare_cover_sets,
				     v_array<v_array<d_node> > &spare_zero_sets,int dim,int K)
{
  if (current_scale > max_scale) // All remaining points are in the zero set.
    brute_nearest(query, zero_set, upper_bound, results, spare_zero_sets,dim,K);
  else
    if (query->scale <= current_scale && query->scale != 100)
      // Our query has too much scale.  Reduce.
      {
	node *query_chi = query->children;
	v_array<d_node> new_zero_set = pop(spare_zero_sets);
	v_array<v_array<d_node> > new_cover_sets = get_cover_sets(spare_cover_sets);
	float* new_upper_bound = alloc_upper();

	node *child_end = query->children + query->num_children;
	for (query_chi++; query_chi != child_end; query_chi++)
	  {
	    setter(new_upper_bound,*upper_bound + query_chi->parent_dist);
	    copy_zero_set(query_chi, new_upper_bound, zero_set, new_zero_set);
	    copy_cover_sets(query_chi, new_upper_bound, cover_sets, new_cover_sets,
			      current_scale, max_scale);
	    internal_batch_nearest_neighbor(query_chi, new_cover_sets, new_zero_set,
					    current_scale, max_scale, new_upper_bound,
                         results, spare_cover_sets, spare_zero_sets,dim,K);
	  }
	free (new_upper_bound);
	new_zero_set.index = 0;
	push(spare_zero_sets, new_zero_set);
	push(spare_cover_sets, new_cover_sets);
	internal_batch_nearest_neighbor(query->children, cover_sets, zero_set,
					current_scale, max_scale, upper_bound, results,
					spare_cover_sets, spare_zero_sets,dim,K);
      }
    else // reduce cover set scale
      {
	halfsort(cover_sets[current_scale]);
	descend(query, upper_bound, current_scale, max_scale,cover_sets, zero_set);
	cover_sets[current_scale++].index = 0;
	internal_batch_nearest_neighbor(query, cover_sets, zero_set,
					current_scale, max_scale, upper_bound, results,
					spare_cover_sets, spare_zero_sets,dim,K);
      }
}

void batch_nearest_neighbor_new(const node &top_node, const node &query,
			    v_array<v_array<float> > &results, int dim,int K)
{
  v_array<v_array<v_array<d_node> > > spare_cover_sets;
  v_array<v_array<d_node> > spare_zero_sets;

  v_array<v_array<d_node> > cover_sets = get_cover_sets(spare_cover_sets);
  v_array<d_node> zero_set = pop(spare_zero_sets);

  float* upper_bound = alloc_upper();
  setter(upper_bound,MAXFLOAT);

  float top_dist = distance(query.p, top_node.p, MAXFLOAT);
  update(upper_bound, top_dist);
  d_node temp = {top_dist, &top_node};
  push(cover_sets[0], temp);

  internal_batch_nearest_neighbor_new(&query,cover_sets,zero_set,0,0,upper_bound,results,
				  spare_cover_sets,spare_zero_sets,dim,K);

  free(upper_bound);
  push(spare_cover_sets, cover_sets);

  for (int i = 0; i < spare_cover_sets.index; i++)
  {
      v_array<v_array<d_node> > cover_sets = spare_cover_sets[i];
      for (int j = 0; j < cover_sets.index; j++)
	  free (cover_sets[j].elements);
      free(cover_sets.elements);
  }
  free(spare_cover_sets.elements);
  push(spare_zero_sets, zero_set);

  for(int i = 0; i < spare_zero_sets.index; i++)
      free(spare_zero_sets[i].elements);
  free(spare_zero_sets.elements);
}


void batch_nearest_neighbor(const node &top_node, const node &query,
			    v_array<v_array<float> > &results, int dim, int K)
{
  v_array<v_array<v_array<d_node> > > spare_cover_sets;
  v_array<v_array<d_node> > spare_zero_sets;

  v_array<v_array<d_node> > cover_sets = get_cover_sets(spare_cover_sets);
  v_array<d_node> zero_set = pop(spare_zero_sets);

  float* upper_bound = alloc_upper();
  setter(upper_bound,MAXFLOAT);

  float top_dist = distance(query.p, top_node.p, MAXFLOAT);
  update(upper_bound, top_dist);
  d_node temp = {top_dist, &top_node};
  push(cover_sets[0], temp);

  internal_batch_nearest_neighbor(&query,cover_sets,zero_set,0,0,upper_bound,results,
				  spare_cover_sets,spare_zero_sets,dim,K);

  free(upper_bound);
  push(spare_cover_sets, cover_sets);

  for (int i = 0; i < spare_cover_sets.index; i++)
    {
      v_array<v_array<d_node> > cover_sets = spare_cover_sets[i];
      for (int j = 0; j < cover_sets.index; j++)
	free (cover_sets[j].elements);
      free(cover_sets.elements);
    }
  free(spare_cover_sets.elements);

  push(spare_zero_sets, zero_set);

  for (int i = 0; i < spare_zero_sets.index; i++)
    free(spare_zero_sets[i].elements);
  free(spare_zero_sets.elements);
}

void k_nearest_neighbor(const node &top_node, const node &query,
			v_array<v_array<float> > &results, int k, int dim)
{

  internal_k = k;
  update = update_k;
  setter = set_k;
  alloc_upper = alloc_k;

  batch_nearest_neighbor(top_node, query,results,dim,k);
}

void k_nearest_neighbor_new(const node &top_node, const node &query,
			v_array<v_array<float> > &results, int k, int dim)
{

  internal_k = k;
  update = update_k;
  setter = set_k;
  alloc_upper = alloc_k;

  batch_nearest_neighbor_new(top_node, query,results,dim,k);
}


void epsilon_nearest_neighbor(const node &top_node, const node &query,
			      v_array<v_array<float> > &results, float epsilon,int dim,int K)
{
  internal_epsilon = epsilon;
  update = update_epsilon;
  setter = set_epsilon;
  alloc_upper = alloc_epsilon;

  batch_nearest_neighbor(top_node, query,results,dim,K);
}

void unequal_nearest_neighbor(const node &top_node, const node &query,
			      v_array<v_array<float> > &results,int dim,int K)
{
  update = update_unequal;
  setter = set_unequal;
  alloc_upper = alloc_unequal;

  batch_nearest_neighbor(top_node, query, results,dim,K);
}
