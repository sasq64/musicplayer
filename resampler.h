#ifndef _RESAMPLER_H_
#define _RESAMPLER_H_

void * rs_create(void);
void rs_delete(void *);
void * rs_dup(const void *);
void rs_dup_inplace(void *, const void *);

int rs_get_free_count(void *);
void rs_write_sample(void *, short sample_l, short sample_r);
void rs_set_rate( void *, double new_factor );
int rs_ready(void *);
void rs_clear(void *);
int rs_get_sample_count(void *);
void rs_get_sample(void *, short * sample_l, short * sample_r);
void rs_remove_sample(void *);

#endif
