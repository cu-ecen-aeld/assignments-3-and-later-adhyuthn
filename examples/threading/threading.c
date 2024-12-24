#include "threading.h"
#include <pthread.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    struct thread_data * thread_func_args = (struct thread_data *) thread_param;
    usleep(thread_func_args->wait_to_obtain_ms);
    pthread_mutex_lock(thread_func_args->mutex);
    usleep(thread_func_args->wait_to_release_ms);
    pthread_mutex_unlock(thread_func_args->mutex);
    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
    
    struct thread_data * thread_data_args = malloc(sizeof(struct thread_data));
    thread_data_args->wait_to_obtain_ms = wait_to_obtain_ms;
    thread_data_args->wait_to_release_ms = wait_to_release_ms;
    thread_data_args->mutex = mutex;

    // TODO: call pthread_create with threadfunc as the entrypoint
    // Get back the reurn val Check the value.

    // NOTE: this function only creataes a thread. It's a wrapper function.
    // return value of thread_func is tested by the program which calls this function.
    if ( pthread_create(thread, NULL, threadfunc, (void *) thread_data_args) != 0) {
        free(thread_data_args);
        return false;
    }
    thread_data_args->thread_complete_success = true;
    return true;
}

