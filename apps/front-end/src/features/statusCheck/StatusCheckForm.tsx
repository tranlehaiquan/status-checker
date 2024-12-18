import React from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { useMutation } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { StatusCheckRecord } from '@/api/types';
import { createStatusCheck } from '@/api';

interface Props {
  className?: string;
  onSuccessfulSubmit?: (params: StatusCheckRecord) => void;
};

const schema = yup.object({
  url: yup.string().url('Please enter a valid URL').required('URL is required'),
});

type FormFields = {
  url: string;
};

const StatusCheckForm: React.FC<Props> = ({ className, onSuccessfulSubmit }) => {
  const { register, handleSubmit, formState: { errors } } = useForm<FormFields>({
    resolver: yupResolver(schema)
  });

  const mutation = useMutation({
    mutationFn: createStatusCheck,
    onSuccess: (data) => {
      onSuccessfulSubmit?.(data);
    },
  });

  const onSubmit = (data: FormFields) => {
    mutation.mutate(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className={className}>
      <div className="space-y-2">
        <Input
          {...register('url')}
          placeholder="Enter URL to check"
        />
        {errors.url?.message && (
          <p className="text-red-500 text-sm">{errors.url.message}</p>
        )}
        <Button 
          type="submit" 
          className="w-full"
          disabled={mutation.isPending}
        >
          {mutation.isPending ? 'Checking...' : 'Check Status'}
        </Button>
      </div>
    </form>
  );
}

export default StatusCheckForm;